export function instanceOfClass(instance, class_) {
  try {
    return instance instanceof class_;
  } catch {
    return false;
  }
}

export async function collectAsync(iterable) {
  const values = [];

  for await (const value of iterable) {
    values.push(value);
  }

  return values;
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

export function callEngineFactory(context, factory) {
  return factory(context);
}

export function globalWebSocketOrUndefined() {
  return globalThis.WebSocket;
}

export function uint8ArrayToArray(bytes) {
  return Array.from(bytes);
}

export const nullValue = null;
