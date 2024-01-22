pub class Dotenv {
    pub static extern "./dotenv.js" inflight config(): void;
    pub static extern "./dotenv.js" preflightConfig(): void;
    pub static extern "./dotenv.js" env(): Map<str>;
}
