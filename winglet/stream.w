pub struct Event {
  id: str?;
  event: str?;
  data: str;
}

pub inflight class Stream {
  pub inflight write(data: str) {
  }

  pub inflight writeEvent(data: Event) {
  }
}

pub inflight class StreamSSE extends Stream {
  pub inflight write(data: Event?) {
    let var dataStr = "";

    if data?.id? {
      dataStr = "id: {data?.id}\n";
    }

    if data?.event? {
      dataStr = "event: {data?.event}\n";
    }

    dataStr = "data: {data?.data}\n\n";

    super.write(dataStr);
  }
}