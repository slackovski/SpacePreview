// ES Module (.mjs)
export const PI = 3.14159;

export async function fetchData(url) {
  const res = await fetch(url);
  if (!res.ok) throw new Error(`HTTP ${res.status}`);
  return res.json();
}

export default class EventBus {
  #listeners = new Map();

  on(event, fn) {
    const list = this.#listeners.get(event) ?? [];
    this.#listeners.set(event, [...list, fn]);
    return () => this.off(event, fn);
  }

  off(event, fn) {
    const list = this.#listeners.get(event) ?? [];
    this.#listeners.set(event, list.filter(f => f !== fn));
  }

  emit(event, ...args) {
    (this.#listeners.get(event) ?? []).forEach(fn => fn(...args));
  }
}
