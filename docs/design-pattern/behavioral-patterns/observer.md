---
title: 옵저버 패턴
description: 옵저버 패턴은 관찰 대상의 이벤트를 여러 구독자에게 알리는 구독 메커니즘을 정의하는 행동 패턴입니다.
sidebar_position: 3
tags:
  - design-pattern
---

> 옵서버 패턴은 당신이 여러 객체에 자신이 관찰 중인 객체에 발생하는 모든 이벤트에 대하여 알리는 구독 메커니즘을 정의할 수 있도록 하는 행동 디자인 패턴입니다

## Overview

- 매장에서 신제품을 기다리는 손님이 있다고 가정해 봅니다.
- 이때 손님 입장에서는 매장에서 손님들에게 재고 현황을 주기적으로 전송해주길 바랄 수 있습니다.
- 하지만 원하는 신제품이 있는지 없는지 손님은 항상 체크를 해야 하고 이는 불편함을 야기시킵니다.
- 원하는 제품이 나왔을 때에만 알림을 받을 방법이 있다면 모두가 행복할것이다!
- 이것이 옵저버 패턴의 핵심

## Terminology

- Publisher: 다른 객체들에 관심 이벤트를 발행하는 객체
  - Subscriber들이 publish상태를 변경시킬 수 있는 메소드를 제공합니다
- Subscriber: 알림 인터페이스를 선언하는 인터페이스
  - 대부분의 경우 단일 update 메소드를 가집니다
  - 파라미터에는 Publisher 가 전달하는 이벤트에 대한 정보를 함께 가질 수 있습니다
- Concrete subscriber: Publisher가 발행한 알림에 대한 응답으로 몇가지 작업을 수행합니다
  - Publisher와 결합되지 않도록 같은 인터페이스를 구현해야 합니다

## Implementation

```ts
interface Context<T> {
  data: T;
  name: string;
}

// Subscriber interface: 알림 인터페이스를 선언
interface Subscriber<T> {
  update(ctx: Context<T>): void;
}

// Concrete subscriber: publisher의 이벤트 발행에 응답
class ConcreteSubscriber implements Subscriber<number> {
  public update(ctx: Context<number>): void {
    console.log("event name:", ctx.name, "with data:", ctx.data.toString());
  }
}

// Publisher: 다른 객체들에 관심 이벤트를 발행
class Publisher {
  public subscribers: Subscriber<number>[] = [];

  public subscribe(subscriber: Subscriber<number>) {
    this.subscribers.push(subscriber);
  }

  public notifySubscribers(ctx: Context<number>) {
    this.subscribers.forEach((subscriber) => subscriber.update(ctx));
  }

  public unsubscribe(subscriber: Subscriber<number>) {
    this.subscribers = this.subscribers.filter((sub) => sub !== subscriber);
  }

  public mainBusinessLogic(input: number) {
    if (input > 10) return;
    this.notifySubscribers({
      name: "valid_input",
      data: input,
    });
  }
}

class Client {
  public static run() {
    const publisher = new Publisher();
    const s1 = new ConcreteSubscriber();
    const s2 = new ConcreteSubscriber();

    publisher.subscribe(s1);
    publisher.subscribe(s2);

    publisher.mainBusinessLogic(29); // nothing happens
    publisher.mainBusinessLogic(8); // event name: valid_input with data: 8 (twice)
  }
}

Client.run();
```

## Usecases

### Store implementation

```ts
// src/Store.ts
export type Reducer<S, A> = (state: S, action: A) => S;
export type Listener<S> = (state: S) => void;

export interface IStore<S, A> {
  state: S;
  dispatch(action: A): void;
  subscribe(listener: Listener<S>): void;
}

export class Store<S, A> implements IStore<S, A> {
  private listeners: ((state: S) => void)[] = [];

  constructor(public state: S, public reducer: Reducer<S, A>) {}

  public dispatch(action: A): void {
    this.state = this.reducer(this.state, action);
    this.listeners.forEach((listener) => listener(this.state));
  }

  public subscribe(listener: Listener<S>): void {
    this.listeners.push(listener);
  }

  public unsubscribe(listener: Listener<S>): void {
    this.listeners = this.listeners.filter((l) => l !== listener);
  }
}

// src/Calendar/application/store.ts
import { Store } from "../../Store";

export interface CalendarState {
  year: number;
  month: number;
  showListView: boolean;
}

export type CalendarAction =
  | { type: "toggleListView" }
  | { type: "previousMonth" }
  | { type: "nextMonth" }
  | { type: "gotoToday" };

export const calendarStore = new Store<CalendarState, CalendarAction>(
  {
    year: new Date().getFullYear(),
    month: new Date().getMonth() + 1,
    showListView: false,
  },
  (state, action) => {
    switch (action.type) {
      case "toggleListView":
        return { ...state, showListView: !state.showListView };
      case "previousMonth":
        return {
          ...state,
          month: state.month === 1 ? 12 : state.month - 1,
          year: state.month === 1 ? state.year - 1 : state.year,
        };
      case "nextMonth":
        return {
          ...state,
          month: state.month === 12 ? 1 : state.month + 1,
          year: state.month === 12 ? state.year + 1 : state.year,
        };
      case "gotoToday":
        return {
          ...state,
          month: new Date().getMonth() + 1,
          year: new Date().getFullYear(),
        };
    }
  }
);

// src/Calendar/ui/Calendar.ts
export class Calendar extends Component {
  private store = calendarStore;

  // ...

  public hydrate(): void {
    this.store.subscribe(this.render);
  }

  public teardown(): void {
    this.store.unsubscribe(this.render);
  }
}
```

전체 코드 레퍼런스: https://github.com/rudy3091/app/blob/master/src/Calendar/ui/Calendar.ts

## Wrap Up
옵저버 패턴은 Behavioral Patterns에 속하는 디자인 패턴입니다. 원문에서 다룬 문제 상황, 해결 구조, TypeScript 예제를 중심으로 핵심 흐름을 정리했습니다.

### Summary
옵저버 패턴은 관찰 대상의 이벤트를 여러 구독자에게 알리는 구독 메커니즘을 정의하는 행동 패턴입니다. 원문 코드와 용어 설명을 최대한 유지하여 패턴의 의도와 적용 지점을 함께 확인할 수 있도록 구성했습니다. 실제 적용 시에는 클라이언트 코드가 구상 클래스에 직접 의존하는 정도, 책임이 한 클래스에 몰리는 정도, 런타임에 조합이 필요한지 여부를 함께 살펴보는 것이 좋습니다.

### Reference
- [Refactoring.guru](https://refactoring.guru/)
