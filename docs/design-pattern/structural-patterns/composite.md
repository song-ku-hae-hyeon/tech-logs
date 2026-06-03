---
title: 복합체 패턴
description: 복합체 패턴은 객체들을 트리 구조로 구성하고 단일 객체와 복합 객체를 같은 방식으로 다루는 구조 패턴입니다.
sidebar_position: 3
tags:
  - design-pattern
---

> 복합체 패턴은 객체들을 트리 구조들로 구성한 후, 이러한 구조들과 개별 객체들처럼 작업할 수 있도록 하는 구조 패턴입니다.

## Overview

- 주문 시스템에서 여러 제품들과 제품들이 들어있는 여러 상자들을 다룬다고 가정하면,
- 최상단의 주문 객체는 하위 객체들을 담고 있고, 각 하위 객체는 자신의 하위 객체를 가지게 됩니다
- 트리 형태의 객체 구조가 형성되는데, 이러한 경우 해당 주문의 총 가격은 어떻게 계산할까?
- 하나의 해결책으로서 이 트리를 재귀적으로 순회하며 총액을 계산할 수 있는데, 이에 최적화된 구조가 `복합체 패턴`

## Terminology

- Component: 트리 구조의 단순 요소들과 복잡한 요소들의 공통 동작을 정의하는 인터페이스
- Leaf: 트리의 기본 요소, 하위 요소가 없습니다
    - 일반적으로 하위요소가 없기 때문에 대부분의 실제 작업을 수행합니다
- Container(Composite): 하위 요소들이 존재하는 요소
    - 자녀들의 구상 클래스를 알지 못하며, Component 인터페이스를 통해 하위 요소들과 함께 작동합니다
    - 요청을 전달받으면 컨테이너는 작업을 하위 요소들에 위임하고 중간 결과를 처리한 다음 최종 결과를 클라이언트에 반환합니다
- Client: 컴포넌트 인터페이스를 통해 모든 요소들과 함께 작동
    - 클라이언트는 트리의 단순 요소들 또는 복잡한 요소들 모두에 대해 같은 방식으로 작업할 수 있습니다.

## Implementation

```ts
// 관련 객체들은 execute 메소드를 가지고, 숫자를 반환한다
interface Component {
  execute(): number;
}

// Leaf 클래스는 execute 동작에 자신이 가지고 있는 고유한 값을 반환한다
class Leaf implements Component {
  constructor(private value: number) {}

  execute(): number {
    return this.value;
  }
}

// Composite 클래스는 execute 동작에 자신이 가지고 있는 자식 클래스들의 값의 합산을 반환한다
class Composite implements Component {
  private children: Component[] = [];

  add(component: Component): void {
    this.children.push(component);
  }

  execute(): number {
    return this.children
      .map((x) => x.execute())
      .reduce((acc, x) => acc + x, 0);
  }
}

class Client {
  static clientCode(component: Component) {
    console.log(`RESULT: ${component.execute()}`);
  }
}

// root도 Composite 객체로서, 하위에 존재하는 Leaf 들의 고유한 값을 모두 합산한 값을 계산할 수 있는 기능을 가진다
const root = new Composite();

const parent1 = new Composite();
parent1.add(new Leaf(1));

const parent2 = new Composite();
parent2.add(new Leaf(2));
parent2.add(new Leaf(3));

root.add(parent1);
root.add(parent2);

Client.clientCode(root); // RESULT: 6
```

## Usecase

### #1 vanilla typescript UI 컴포넌트

- UI 컴포넌트는 최상위 컴포넌트를 마운트하더라도 하위의 자식 컴포넌트들이 모두 함께 마운트됩니다
- 아래 예제에서는 `render` 메소드가 Composite 객체와 Leaf 객체의 동작을 정의합니다

```ts
// Component
export interface IComponent {
  root(): HTMLElement;
  children?: IComponent[];
  template(): string;
  render(): void;
  unMount(): void;
  hydrate(): void;
  teardown(): void;
}

// Leaf
export abstract class Component implements IComponent {
  root = () => document.body;
  children: IComponent[] = [];

  public abstract template(): string;

  public alignChildren() {}

  public render() {
    this.alignChildren();
    this.root().innerHTML = this.template();
    this.children.forEach(child => child.render());
    this.children.forEach(child => child.hydrate());
  }

  public unMount() {
    this.children.forEach(child => child.teardown());
    this.children.forEach(child => child.unMount());
    this.root().innerHTML = '';
  }

  public hydrate() {}

  public teardown() {}
}

// Composite
export class Calendar extends Component {
  private year: Year<T>;
  private month: Month<T>;
  // ...

  constructor(public root: Root, year: number, month: number) {
    super();
    this.year = new Year(year);
    this.month = new Month(month, this.year.isLeapYear());
    // ...
  }

  // ...

  public template() {
    // ...
  }

  // ...
}

// Composite
export class Application extends Component {
  public calendar: Calendar;

  constructor(public root: Root) {
    super();
    this.calendar = new Calendar(
      () => this.root().querySelector('.calendar-slot')!,
      new Date().getFullYear(),
      new Date().getMonth() + 1
    );
    this.children.push(this.calendar);
  }

  public template(): string {
    return `
      <div class="app">
        <div class="calendar-slot">Calendar is not available</div>
      </div>
    `;
  }

  // Client
  public static main() {
    const component = new Application(document.body);
    component.render();
    component.hydrate();
  }
}

Application.main();
```

### #2 Calendar hierarchy

- 달력을 모델링하는 객체 구조에서, 연 - 월 - 주 - 일 의 상하관계를 가지는 계층구조가 존재합니다
- 이때 가장 하위의 일 객체에만 문자열 데이터를 저장한다고 가정할 때, 해당 패턴을 적용할 수 있습니다
- 특정한 계층구조 구성요소를 전달하면, 하위에 존재하는 모든 데이터를 아래와 같이 배열 형태로 가져올 수 있습니다

```ts
// Component interfaces
// 객체들의 공통 동작을 정의 가능
export interface Retrievable<T> {
  retrieve(): T;
}

export interface CalendarComponent<T> extends Retrievable<T> {
  year?: number;
  month?: number;
  week?: number;
  number: number;
}

export interface RetrievedData<T> {
  year?: number;
  month?: number;
  week?: number;
  day?: number;
  data: T;
}

// Leaf class
// 실제 작업(데이터 반환)을 처리하는 객체, 작업을 위임할 하위요소 없음
export class Day implements Clonable<Day>, CalendarComponent<RetrievedData<string | null>> {
  public data: string | null = null;
  public isCurrentMonth = true;

  constructor(
    public year: number,
    public month: number,
    public week: number,
    public number: number,
    public readonly day: DayOfWeek,
    public isToday = false
  ) {}

  public retrieve(): RetrievedData<string | null> {
    return {
      year: this.year,
      month: this.month,
      day: this.number,
      week: this.week,
      data: this.data,
    };
  }

  public clone(): Day {
    // ...
  }
}

// Composite classes
// 하위 요소들을 가지는 요소, 컴포넌트 인터페이스를 통해서만 하위요소들과 함께 동작
// Year -> Month -> Week -> Day 순서의 계층구조
export class Week implements CalendarComponent<RetrievedData<string>[]> {
  public days: CalendarComponent<RetrievedData<string | null>>[] = [];

  constructor(
    public year: number,
    public month: number,
    public readonly number: number,
    public readonly firstDay: DayOfWeek,
    public readonly firstDate: number,
    public readonly lastDateOfMonth: number,
    public readonly formerMonthDays: number
  ) {
    this.days = this.createDays();
  }

  public retrieve(): RetrievedData<string>[] {
    return this.days.flatMap(day => day.retrieve()).filter((data): data is RetrievedData<string> => !!data.data);
  }

  private createDays(): CalendarComponent<RetrievedData<string | null>>[] {
    // ...
  }
}

export class Month implements CalendarComponent<RetrievedData<string>[]> {
  public weeks: CalendarComponent<RetrievedData<string>[]>[] = [];

  constructor(public year: number, public readonly number: number) {}

  public retrieve(): RetrievedData<string>[] {
    return this.weeks.flatMap(week => week.retrieve());
  }

  // ...
}

export class Year implements CalendarComponent<RetrievedData<string>[]> {
  public months: Array<CalendarComponent<RetrievedData<string>[]> | null> = new Array(12)
    .fill(null)
    .map((_, index) => new Month(this.number, index + 1));

  constructor(public readonly number: number) {}

  public retrieve(): RetrievedData<string>[] {
    return this.months.flatMap(month => {
      if (!month) return [];
      const monthData = month.retrieve();
      return monthData.map(data => ({ ...data, month: month.number }));
    });
  }

  // ...
}

// Client code
// 생성자의 `scope` 필드로 주어지는 Component 인터페이스를 통해 하위요소들의 데이터를 모두 가져와 보여주게 됨
export class CalendarListView extends Component {
  constructor(public root: Root, public scope?: CalendarComponent<RetrievedData<string>[]>) {
    super();
  }

  public alignChildren(): void {
    const data = this.scope?.retrieve() ?? [];
    this.children = data.map(
      (item, index) =>
        new CalendarListViewEntry(
          () => this.root().querySelector(`.calendar-list-entry-slot:nth-child(${index + 1})`)!,
          item
        )
    );
  }

  public template(): string {
    return `
      <div class="calendar-list-view">
        ${
          this.children.length === 0
            ? 'No data available.'
            : '<div class="calendar-list-entry-slot"></div>'.repeat(this.children.length)
        }
      </div>
    `;
  }
}
```

- Full code reference: https://github.com/rudy3091/app/blob/master/src/Calendar/ui/Calendar.ts

## Wrap Up
복합체 패턴은 Structural Patterns에 속하는 디자인 패턴입니다. 원문에서 다룬 문제 상황, 해결 구조, TypeScript 예제를 중심으로 핵심 흐름을 정리했습니다.

### Summary
복합체 패턴은 객체들을 트리 구조로 구성하고 단일 객체와 복합 객체를 같은 방식으로 다루는 구조 패턴입니다. 원문 코드와 용어 설명을 최대한 유지하여 패턴의 의도와 적용 지점을 함께 확인할 수 있도록 구성했습니다. 실제 적용 시에는 클라이언트 코드가 구상 클래스에 직접 의존하는 정도, 책임이 한 클래스에 몰리는 정도, 런타임에 조합이 필요한지 여부를 함께 살펴보는 것이 좋습니다.

### Reference
- [Refactoring.guru](https://refactoring.guru/)
