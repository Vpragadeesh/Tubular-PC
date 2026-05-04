use anyhow::{bail, Result};
use serde::{Deserialize, Serialize};
use std::sync::Arc;
use tokio::sync::RwLock;

#[derive(Debug, Clone, Serialize, Deserialize, PartialEq, Eq)]
#[serde(rename_all = "snake_case")]
pub enum PlaybackStatus {
    Idle,
    Playing,
    Paused,
    Stopped,
    Error,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct PlayerState {
    pub status: PlaybackStatus,
    pub video_id: Option<String>,
    pub stream_url: Option<String>,
    pub position_seconds: f64,
    pub duration_seconds: Option<f64>,
    pub background_audio: bool,
    pub error: Option<String>,
    pub updated_at: String,
}

impl Default for PlayerState {
    fn default() -> Self {
        Self {
            status: PlaybackStatus::Idle,
            video_id: None,
            stream_url: None,
            position_seconds: 0.0,
            duration_seconds: None,
            background_audio: false,
            error: None,
            updated_at: now(),
        }
    }
}

#[derive(Debug, Deserialize)]
pub struct PlayRequest {
    pub video_id: String,
    pub stream_url: String,
    pub duration_seconds: Option<f64>,
    #[serde(default)]
    pub start_position_seconds: f64,
    #[serde(default)]
    pub background_audio: bool,
}

#[derive(Debug, Deserialize)]
pub struct SeekRequest {
    pub position_seconds: f64,
}

#[derive(Debug, Deserialize)]
pub struct BackgroundAudioRequest {
    pub enabled: bool,
}

#[derive(Debug, Clone, Default)]
pub struct PlayerHandle {
    state: Arc<RwLock<PlayerState>>,
}

impl PlayerHandle {
    pub fn new() -> Self {
        Self::default()
    }

    pub async fn snapshot(&self) -> PlayerState {
        self.state.read().await.clone()
    }

    pub async fn play(&self, request: PlayRequest) -> Result<PlayerState> {
        validate_play_request(&request)?;

        let mut state = self.state.write().await;
        state.status = PlaybackStatus::Playing;
        state.video_id = Some(request.video_id);
        state.stream_url = Some(request.stream_url);
        state.duration_seconds = request.duration_seconds.filter(|value| *value > 0.0);
        state.position_seconds = clamp_position(
            request.start_position_seconds,
            state.duration_seconds,
        )?;
        state.background_audio = request.background_audio;
        state.error = None;
        state.updated_at = now();

        Ok(state.clone())
    }

    pub async fn pause(&self) -> Result<PlayerState> {
        let mut state = self.state.write().await;
        ensure_loaded(&state)?;

        if state.status == PlaybackStatus::Playing {
            state.status = PlaybackStatus::Paused;
            state.updated_at = now();
        }

        Ok(state.clone())
    }

    pub async fn resume(&self) -> Result<PlayerState> {
        let mut state = self.state.write().await;
        ensure_loaded(&state)?;

        if matches!(state.status, PlaybackStatus::Paused | PlaybackStatus::Stopped) {
            state.status = PlaybackStatus::Playing;
            state.error = None;
            state.updated_at = now();
        }

        Ok(state.clone())
    }

    pub async fn seek(&self, request: SeekRequest) -> Result<PlayerState> {
        let mut state = self.state.write().await;
        ensure_loaded(&state)?;

        state.position_seconds = clamp_position(request.position_seconds, state.duration_seconds)?;
        state.updated_at = now();

        Ok(state.clone())
    }

    pub async fn set_background_audio(
        &self,
        request: BackgroundAudioRequest,
    ) -> Result<PlayerState> {
        let mut state = self.state.write().await;
        ensure_loaded(&state)?;

        state.background_audio = request.enabled;
        state.updated_at = now();

        Ok(state.clone())
    }

    pub async fn stop(&self) -> PlayerState {
        let mut state = self.state.write().await;
        *state = PlayerState {
            status: PlaybackStatus::Stopped,
            updated_at: now(),
            ..PlayerState::default()
        };

        state.clone()
    }
}

fn validate_play_request(request: &PlayRequest) -> Result<()> {
    if request.video_id.trim().is_empty() {
        bail!("video_id is required");
    }

    if request.stream_url.trim().is_empty() {
        bail!("stream_url is required");
    }

    if request
        .duration_seconds
        .is_some_and(|duration| !duration.is_finite() || duration < 0.0)
    {
        bail!("duration_seconds must be a positive finite number");
    }

    if !request.start_position_seconds.is_finite() || request.start_position_seconds < 0.0 {
        bail!("start_position_seconds must be a positive finite number");
    }

    Ok(())
}

fn ensure_loaded(state: &PlayerState) -> Result<()> {
    if state.video_id.is_none() || state.stream_url.is_none() {
        bail!("no media is loaded");
    }

    Ok(())
}

fn clamp_position(position_seconds: f64, duration_seconds: Option<f64>) -> Result<f64> {
    if !position_seconds.is_finite() || position_seconds < 0.0 {
        bail!("position_seconds must be a positive finite number");
    }

    Ok(match duration_seconds {
        Some(duration) if duration > 0.0 => position_seconds.min(duration),
        _ => position_seconds,
    })
}

fn now() -> String {
    chrono::Utc::now().to_rfc3339()
}

#[cfg(test)]
mod tests {
    use super::*;

    fn play_request() -> PlayRequest {
        PlayRequest {
            video_id: "video-1".to_string(),
            stream_url: "https://example.invalid/video".to_string(),
            duration_seconds: Some(120.0),
            start_position_seconds: 0.0,
            background_audio: false,
        }
    }

    #[tokio::test]
    async fn play_sets_single_global_state() {
        let player = PlayerHandle::new();

        let state = player.play(play_request()).await.expect("play succeeds");

        assert_eq!(state.status, PlaybackStatus::Playing);
        assert_eq!(state.video_id.as_deref(), Some("video-1"));
        assert_eq!(
            state.stream_url.as_deref(),
            Some("https://example.invalid/video")
        );
        assert_eq!(state.position_seconds, 0.0);
        assert_eq!(state.duration_seconds, Some(120.0));
    }

    #[tokio::test]
    async fn seek_clamps_to_known_duration() {
        let player = PlayerHandle::new();
        player.play(play_request()).await.expect("play succeeds");

        let state = player
            .seek(SeekRequest {
                position_seconds: 240.0,
            })
            .await
            .expect("seek succeeds");

        assert_eq!(state.position_seconds, 120.0);
    }

    #[tokio::test]
    async fn pause_without_loaded_media_returns_error() {
        let player = PlayerHandle::new();

        let result = player.pause().await;

        assert!(result.is_err());
    }
}
