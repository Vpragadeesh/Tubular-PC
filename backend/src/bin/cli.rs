use tubular_backend::cli;

#[tokio::main]
async fn main() -> Result<(), Box<dyn std::error::Error>> {
    // Collect command line arguments (skip the first one which is the program name)
    let args = std::env::args().collect::<Vec<String>>();
    
    // Run the CLI with the arguments
    cli::run_cli(args).await
}
