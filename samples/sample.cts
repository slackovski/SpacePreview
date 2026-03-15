import { EventEmitter } from 'events';

interface Message {
  id: string;
  content: string;
  timestamp: Date;
}

class MessageQueue extends EventEmitter {
  private queue: Message[] = [];

  enqueue(message: Message): void {
    this.queue.push(message);
    this.emit('message:added', message);
  }

  dequeue(): Message | undefined {
    const message = this.queue.shift();
    if (message) {
      this.emit('message:removed', message);
    }
    return message;
  }
}

export { MessageQueue, Message };
