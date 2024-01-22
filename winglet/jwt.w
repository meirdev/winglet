pub class jwt {
    pub static extern "./jwt.js" inflight sign(payload: Json, secret: str): str;
    pub static extern "./jwt.js" inflight verify(token: str, secret: str): Json;
}
