pub struct Event {
  id: str?;
  event: str?;
  data: str;
}

pub inflight class Stream {
  pub inflight write(data: str) {
  }
}

pub inflight class StreamSSE extends Stream {
  pub inflight write(data: Event?) {
  }
}
