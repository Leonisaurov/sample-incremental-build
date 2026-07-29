fn main() {
    println!("termux-sample v{}", env!("CARGO_PKG_VERSION"));
    println!("OS: {} / Arch: {}", std::env::consts::OS, std::env::consts::ARCH);
    if let Ok(p) = std::env::var("PREFIX") {
        println!("PREFIX: {}", p);
    }
    if let Ok(h) = std::env::var("HOME") {
        println!("HOME: {}", h);
    }
    // incremental build test - 2026-07-29
}
