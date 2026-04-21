export function instanceOfClass(instance, class_) {
  try {
    return instance instanceof class_;
  } catch {
    return false;
  }
}

export async function collectAsync(iterable) {
  return Array.fromAsync(iterable);
}

export async function forEachAsync(iterable, fn) {
  for await (const value of iterable) {
    fn(value);
  }
}

export function subscribeEvent(target, event, listener) {
  return target.subscribe(event, (...payload) => listener(payload));
}

export function publisherSubscribeFirst(publisher, events) {
  return publisher.subscribeFirst(...events);
}

export function publisherPublish(publisher, event, payload) {
  publisher.publish(event, ...payload);
}

export function uint8ArrayToArray(bytes) {
  return Array.from(bytes);
}

export const nullValue = null;
