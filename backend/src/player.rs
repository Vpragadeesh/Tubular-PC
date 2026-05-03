use anyhow::{Context, Result};
use std::process::{Child, Command};

#[allow(dead_code)]
pub struct Player {
    process: Option<Child>,
}

#[allow(dead_code)]
impl Player {
    pub fn new() -> Self {
        Self { process: None }
    }

    /// Play video using mpv
    pub fn play(&mut self, stream_url: &str) -> Result<()> {
        // Stop any existing playback
        self.stop();

        let child = Command::new("mpv")
            .arg(stream_url)
            .arg("--no-terminal")
            .arg("--force-window=yes")
            .spawn()
            .context("Failed to start mpv. Make sure mpv is installed.")?;

        self.process = Some(child);
        Ok(())
    }

    /// Stop playback
    pub fn stop(&mut self) {
        if let Some(mut process) = self.process.take() {
            let _ = process.kill();
        }
    }

    /// Check if player is running
    pub fn is_playing(&mut self) -> bool {
        if let Some(process) = &mut self.process {
            process.try_wait().ok().flatten().is_none()
        } else {
            false
        }
    }
}

impl Drop for Player {
    fn drop(&mut self) {
        self.stop();
    }
}

/// Play video in background (audio only)
#[allow(dead_code)]
pub fn play_background(stream_url: &str) -> Result<Child> {
    let child = Command::new("mpv")
        .arg(stream_url)
        .arg("--no-video")
        .arg("--no-terminal")
        .spawn()
        .context("Failed to start mpv for background playback")?;

    Ok(child)
}
