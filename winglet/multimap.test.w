bring "./multimap.w" as multimap;

test "set, get" {
  let map = new multimap.MultiMap();

  assert(map.get("Accept") == nil);

  map.set("Accept", "text/html");

  assert(map.get("Accept") == "text/html");
}

test "append, getAll, set, get" {
  let map = new multimap.MultiMap();

  assert(map.getAll("Accept") == nil);

  map.append("Accept", "text/html");
  map.append("Accept", "application/json");

  assert(map.getAll("Accept") == ["text/html", "application/json"]);

  map.set("Accept", "text/html");

  assert(map.get("Accept") == "text/html");
}

test "set, has, delete" {
  let map = new multimap.MultiMap();

  assert(!map.has("Accept"));

  map.set("Accept", "text/html");

  assert(map.has("Accept"));

  map.delete("Accept");

  assert(!map.has("Accept"));
}

test "set, append, keys, values, entires" {
  let map = new multimap.MultiMap();

  assert(map.keys().length == 0);
  assert(map.values().length == 0);

  map.set("Accept", "text/html");
  map.append("Accept", "text/plain");
  map.set("Cache-Control", "no-cache");

  assert(Json.stringify(map.keys()) == Json.stringify(["Accept", "Cache-Control"]));

  assert(Json.stringify(map.values()) == Json.stringify(["text/html", "text/plain", "no-cache"]));

  assert(Json.stringify(map.entries()) == Json.stringify([["Accept", "text/html"], ["Accept", "text/plain"], ["Cache-Control", "no-cache"]]));
}

test "toMap" {
  let map = new multimap.MultiMap();

  map.append("Content-Type", "text/html");
  map.append("Content-Type", "application/json");
  map.append("Content-Language", "en");
  map.append("Content-Language", "he");
  map.append("User-Agent", "chrome");

  let value = map.toMap(", ");

  let expected: MutMap<str> = {
    "Content-Type": "text/html, application/json",
    "Content-Language": "en, he",
    "User-Agent": "chrome",
  };

  assert(Json.stringify(value) == Json.stringify(expected));
}
