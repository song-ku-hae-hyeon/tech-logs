---
title: 추상 팩토리 패턴
description: 추상 팩토리 패턴은 관련 객체들의 구상 클래스에 직접 의존하지 않고 제품군을 생성하는 방법을 다룹니다.
sidebar_position: 2
tags:
  - design-pattern
---

> 관련 객체들의 구상 클래스들을 지정하지 않고도 관련 객체들의 모음을 생성할 수 있도록 하는 생성패턴입니다

> 당신의 코드가 관련된 제품군의 다양한 패밀리들과 작동해야 하지만 해당 제품들의 구상 클래스들에 의존하고 싶지 않을 때 사용하세요

## Glossary

- Abstract Product:
    - 인터페이스로 선언합니다
    - Product 그룹을 구성하는 Product 타입의 집합의 동작을 기술
- Concrete Product:
    - Abstract Product 를 구현하는 클래스들
    - 각 Abstract Product들은 Product 그룹에 존재하는 모든 바리에이션을 구현해야 합니다
- Abstract Factory:
    - 인터페이스로 선언합니다
    - 각각의 Abstract Product들을 생성하기 위한 여러 메소드들의 집합
    - 리턴 타입은 Abstract Product이어야 합니다
- Concrete Factory:
    - Abstract Factory의 생성 메소드를 구현합니다
    - Concrete Factory의 메소드들은 해당 Product 그룹 내부의 동일한 바리에이션을 생산해냄
    - 하지만 리턴 타입은 Abstract Product(팩토리를 사용하는 클라이언트와의 결합도를 낮추기 위함)

## 유즈케이스 - 드래그 앤 드랍 UI 컴포넌트

- OOP와 디자인 패턴을 활용하기 위해 UI 컴포넌트를 클래스로 만들기
- 드래그 앤 드랍은 HTML 스펙 상 터치 디바이스와 마우스를 사용하는 조작이 별도로 구분됩니다
- 전자는 `touch*` 이벤트, 후자는 `drag*` 이벤트를 이용하여 구현됩니다
- [MDN 문서](https://developer.mozilla.org/en-US/docs/Web/API/HTML_Drag_and_Drop_API) 참고

### Infrastructure

```ts
export interface Component {
  root: () => HTMLElement;
  children?: Component[];

  template(): string;
  render(): void;
  hydrate(): void;
}

export interface ComponentConstructor<T = any> {
  new (root: () => HTMLElement, props?: T): Component;
}
```

- Component 는 `root`를 가지는 인터페이스
- 각각 DOM구조, 렌더링, 이벤트 핸들러 관리를 담당하는 `template`, `render`, `hydrate` 메소드를 가집니다

```ts
function mount(x: ComponentConstructor, root: HTMLElement = document.body) {
  const app = new x(() => root);
  app.render();
  app.hydrate();
}
```

- 컴포넌트를 하나 받아 html에 렌더링해주는 `mount` 함수 선언합니다

### Abstract Product

- Product 는 UI 구성요소들이 해당
- 드래그 앤 드랍을 구현하기 위해 아래 컴포넌트들을 구현합니다
    - `DndContainer` (ProductA)
    - `DndItem` (ProductB)
    - `DndIndicator` (ProductC)
- 먼저 `Abstract Product` 부터 정의합니다

```ts
// DndContainer.ts
import { Component } from '../Component';
import { IDndItem, ToString } from './shared';
import { DndItem } from './DndItem';
import { DndComponentFactory } from './Factory';

export interface DndContainer<T extends ToString> extends Component {
  props: { factory: DndComponentFactory<T>; items: IDndItem<T>[] };
  draggingIndex: number;
  hoveringIndex: number;
  startDrag(evt: Event): void;
  hoverOnItem(evt: Event): void;
  drop(evt: Event): void;
}

// DndItem.ts
import { Component } from '../Component';
import { DndComponentFactory } from './Factory';
import { DndIndicator } from './Indicator';
import { ToString } from './shared';

export interface DndItem<T extends ToString> extends Component {
  props: { factory: DndComponentFactory<T>; draggingIndex: number; index: number; data: T };
  upperIndicator: DndIndicator;
  lowerIndicator: DndIndicator;
  focus(evt: Event): void;
  focusOut(evt: Event): void;
}

// DndIndicator.ts
import { Component } from '../Component';

export interface DndIndicator extends Component {
  enabled: boolean;
  enable(): void;
  disable(): void;
}
```

- 각 인터페이스들은 Component 인터페이스를 상속받아 확장합니다
- `startDrag`, `drop` 과 같이 각 객체의 고유 동작을 추상화합니다
- `props` 필드의 프로퍼티로 `DndComponentFactory` 객체가 이미 정의되어 있는데, 이후 설명

### Concrete Product

- 이들을 구현하는 `Concrete Product` 는 `Web`, `Mobile` 의 두가지 Product Group으로 구분하여 구현합니다
- 또한 `Web` 그룹과 `Mobile` 그룹의 공통 동작은 abstract 클래스로 공통화
    - abstract 클래스는 그 자체로서 바로 인스턴스화 불가능합니다

```ts
// DndContainer.ts
// Abstract DndContainer class
export abstract class DndContainerImpl<T extends ToString> implements DndContainer<T> {
  children: DndItem<T>[] = [];
  draggingIndex: number = -1;
  hoveringIndex: number = -1;

  constructor(
    public root: () => HTMLElement,
    public props: DndContainer<T>['props'],
  ) {
    this.hoverOnItem = this.hoverOnItem.bind(this);
    this.startDrag = this.startDrag.bind(this);
    this.drop = this.drop.bind(this);
    this.moveItem = this.moveItem.bind(this);
    this.alignChildren();
  }

  protected alignChildren(): void {
    this.children = this.props.items.map((child, idx) =>
      this.props.factory.createDndItem(() => this.root().querySelector(`.dnd-item-slot:nth-child(${idx + 1})`)!, {
        factory: this.props.factory,
        draggingIndex: this.draggingIndex,
        index: idx,
        data: child.data,
      }),
    );
  }

  public abstract startDrag(evt: Event): void;

  public abstract hoverOnItem(evt: Event): void;

  protected moveItem(): void {
    const draggingItem = this.props.items[this.draggingIndex];
    this.props.items.splice(this.draggingIndex, 1);
    this.props.items.splice(this.hoveringIndex, 0, draggingItem);
  }

  public drop(_evt: Event): void {
    this.moveItem();
    this.draggingIndex = -1;
    this.hoveringIndex = -1;
    this.render();
  }

  public abstract template(): string;

  public render(): void {
    this.root().innerHTML = this.template();
    this.alignChildren();
    this.children.forEach((item) => item.render());
    this.children.forEach((item) => item.hydrate());
  }

  public abstract hydrate(): void;
}

// Concrete Web DndContainer class
export class WebDndContainer<T extends ToString> extends DndContainerImpl<T> {
  public startDrag(evt: DragEvent): void {
    const target = evt.target as HTMLElement;
    const index = Array.from(target.parentElement?.children || []).indexOf(target);
    this.draggingIndex = index;
    this.children[index].root().style.opacity = '0.4';

    this.alignChildren();
    this.children.forEach((child) => child.render());
    this.children.forEach((child) => child.hydrate());
  }

  public hoverOnItem(evt: Event): void {
    evt.preventDefault();
    const target = evt.target as HTMLElement;
    const slot = target.closest('.dnd-item-slot')!;
    const index = Array.from(slot.parentElement?.children || []).indexOf(slot);

    if (index === this.hoveringIndex) return;
    this.hoveringIndex = index;
  }

  public template(): string {
    return `<div draggable="true" class="dnd-item-slot"></div>`.repeat(this.props.items.length);
  }

  public hydrate(): void {
    this.root().addEventListener('dragstart', this.startDrag);
    this.root().addEventListener('dragover', this.hoverOnItem);
    this.root().addEventListener('drop', this.drop);
  }
}

// Concrete Mobile DndContainer class
export class MobileDndContainer<T extends ToString> extends DndContainerImpl<T> {
  public startDrag(evt: Event): void {
    const target = evt.target as HTMLElement;
    const slot = target.closest('.dnd-item-slot')!;
    const index = Array.from(slot.parentElement?.children || []).indexOf(slot);
    this.draggingIndex = index;
  }

  public hoverOnItem(evt: TouchEvent): void {
    evt.preventDefault();
    const x = evt.touches[0].clientX;
    const y = evt.touches[0].clientY;
    const target = document.elementFromPoint(x, y) as HTMLElement;
    const slot = target.closest('.dnd-item-slot')!;
    const index = Array.from(slot.parentElement?.children || []).indexOf(slot);
    this.hoveringIndex = index;
  }

  public template(): string {
    return `<div class="dnd-item-slot"></div>`.repeat(this.props.items.length);
  }

  public hydrate(): void {
    this.root().addEventListener('touchstart', this.startDrag);
    this.root().addEventListener('touchmove', this.hoverOnItem);
    this.root().addEventListener('touchend', this.drop);
  }
}
```

```ts
// DndItem.ts
// Abstract DndItem class
export abstract class DndItemImpl<T extends ToString> implements DndItem<T> {
  upperIndicator: DndIndicator;
  lowerIndicator: DndIndicator;

  constructor(
    public root: () => HTMLElement,
    public props: DndItem<T>['props'],
  ) {
    this.focus = this.focus.bind(this);
    this.focusOut = this.focusOut.bind(this);
    this.upperIndicator = this.props.factory.createDndIndicator(
      () => root().querySelector('.upper-indicator-slot')!,
    );
    this.lowerIndicator = this.props.factory.createDndIndicator(
      () => root().querySelector('.lower-indicator-slot')!,
    );
  }

  public abstract focus(evt: Event): void;

  public abstract focusOut(evt: Event): void;

  public template(): string {
    const label = this.props.data.toString() ?? '';
    return `
      <div class="upper-indicator-slot"></div>
      <div class="dnd-item">
        <span class="dnd-dash">-</span>
        <span class="dnd-label">${label}</span>
      </div>
      <div class="lower-indicator-slot"></div>
    `;
  }

  public render(): void {
    this.root().innerHTML = this.template();
    this.upperIndicator.render();
  }

  public abstract hydrate(): void;
}

// Concrete Web DndItem class
export class WebDndItem<T extends ToString> extends DndItemImpl<T> {
  public focus(evt: DragEvent): void {
    evt.preventDefault();
    if (this.props.draggingIndex === -1 || this.props.index === this.props.draggingIndex) return;
    this.props.index < this.props.draggingIndex ? this.upperIndicator.enable() : this.lowerIndicator.enable();
    this.upperIndicator.render();
    this.lowerIndicator.render();
  }

  public focusOut(evt: Event): void {
    evt.preventDefault();
    if (this.props.draggingIndex === -1 || this.props.index === this.props.draggingIndex) return;
    this.props.index < this.props.draggingIndex ? this.upperIndicator.disable() : this.lowerIndicator.disable();
    this.upperIndicator.render();
    this.lowerIndicator.render();
  }

  public hydrate(): void {
    this.root().addEventListener('dragenter', this.focus);
    this.root().addEventListener('dragleave', this.focusOut);
  }
}

// Concrete Mobile DndItem class
export class MobileDndItem<T extends ToString> extends DndItemImpl<T> {
  public focus(evt: Event): void {
    evt.preventDefault();
    this.root().style.opacity = '0.4';
  }

  public focusOut(evt: Event): void {
    evt.preventDefault();
    this.root().style.opacity = '1';
  }

  public hydrate(): void {
    this.root().addEventListener('touchstart', this.focus);
    this.root().addEventListener('touchend', this.focusOut);
  }
}
```

```ts
// DndIndicator.ts
export class DndIndicatorImpl implements DndIndicator {
  public enabled: boolean = false;

  constructor(public root: () => HTMLElement) {}

  public enable(): void {
    this.enabled = true;
  }

  public disable(): void {
    this.enabled = false;
  }

  public template(): string {
    return this.enabled
      ? `<div class="indicator" style="width: 300px; height: 2px; background-color: white;"></div>`
      : '';
  }

  public render(): void {
    this.root().innerHTML = this.template();
  }

  public hydrate(): void {}
}
```

- DndIndicator 객체는 두 Product 그룹 공통으로 구현되어 Product 그룹별 구분 없이 통합하여 구현합니다

- 현재까지의 클래스 구조도

```
DndContainer (Interface) - DndContainerImpl (Abstract Class)
|- WebDndContainer (Concrete Class)
|- TouchDndContainer (Concrete Class)

DndItem (Interface) - DndItemImpl (Abstract Class)
|- WebDndItem (Concrete Class)
|- TouchDndItem (Concrete Class)

Indicator (Interface)
|- IndicatorImpl (Concrete Class)
```

### Abstract Factory

- 이러한 Product들을 만들어내는 책임을 가지는 **Factory 역시도 인터페이스를 통해 한단계 추상화**하는 것이 Abstract Factory 패턴의 핵심
- `Web` 그룹과 `Touch` 그룹을 만들어내는 팩토리의 동작을 정의하는 인터페이스 선언합니다

```ts
// Factory.ts
import { DndContainer, WebDndContainer, MobileDndContainer } from './DndContainer';
import { DndItem, WebDndItem, MobileDndItem } from './DndItem';
import { DndIndicator, DndIndicatorImpl } from './Indicator';
import { ToString } from './shared';

export interface DndComponentFactory<T extends ToString> {
  createDndItem(root: () => HTMLElement, props: DndItem<T>['props']): DndItem<T>;
  createDndContainer(root: () => HTMLElement, props: DndContainer<T>['props']): DndContainer<T>;
  createDndIndicator(root: () => HTMLElement): DndIndicator;
}
```

- DndComponentFactory 는 각 Product에 해당하는 컴포넌트 객체들을 생성하는 메소드들을 가집니다
- 두 그룹(`Web`, `Touch`)은 각각 이 인터페이스를 구현한 Concrete 팩토리를 가져야 합니다

### Concrete Factory

```ts
// Web 그룹을 위한 WebDndComponentFactory
export class WebDndComponentFactory<T extends ToString> implements DndComponentFactory<T> {
  createDndItem(root: () => HTMLElement, props: DndItem<T>['props']): DndItem<T> {
    return new WebDndItem(root, props);
  }

  createDndContainer(root: () => HTMLElement, props: DndContainer<T>['props']): DndContainer<T> {
    return new WebDndContainer(root, props);
  }

  createDndIndicator(root: () => HTMLElement): DndIndicator {
    return new DndIndicatorImpl(root);
  }
}

// Touch 그룹을 위한 TouchDndComponentFactory
export class MobileDndComponentFactory<T extends ToString> implements DndComponentFactory<T> {
  createDndItem(root: () => HTMLElement, props: DndItem<T>['props']): DndItem<T> {
    return new MobileDndItem(root, props);
  }

  createDndContainer(root: () => HTMLElement, props: DndContainer<T>['props']): DndContainer<T> {
    return new MobileDndContainer(root, props);
  }

  createDndIndicator(root: () => HTMLElement): DndIndicator {
    return new DndIndicatorImpl(root);
  }
}
```

- 이 Factory 객체를 사용하는 클라이언트 객체들은 각 Factory의 구현에 의존하지 않고 `DndComponentFactory` 인터페이스에 의존하여야 함(Dependency Inversion Principle)
- 또한 각 Factory 객체 메소드들은 Concrete Product 들이 아닌 Abstract Product들을 리턴하여 사용처에서는 Concrete Product 객체들에 의존하지 않게 됩니다
- 아까 Concrete Product 클래스의 생성자를 다시 보면,

```ts
export interface DndItem<T extends ToString> extends Component {
  props: { factory: DndComponentFactory<T>; draggingIndex: number; index: number; data: T };
  upperIndicator: DndIndicator;
  lowerIndicator: DndIndicator;
  focus(evt: Event): void;
  focusOut(evt: Event): void;
}

export abstract class DndItemImpl<T extends ToString> implements DndItem<T> {
  upperIndicator: DndIndicator;
  lowerIndicator: DndIndicator;

  constructor(
    public root: () => HTMLElement,
    public props: DndItem<T>['props'],
  ) {
    this.focus = this.focus.bind(this);
    this.focusOut = this.focusOut.bind(this);
    this.upperIndicator = this.props.factory.createDndIndicator(
      () => root().querySelector('.upper-indicator-slot')!,
    );
    this.lowerIndicator = this.props.factory.createDndIndicator(
      () => root().querySelector('.lower-indicator-slot')!,
    );
  }
// ...
```

- `DndIndicator` 객체를 필드로 가지는데, 이를 `props.factory`를 통해 생성함으로서 위에서 언급한 Concrete Product에 직접 의존하지 않는 구조를 가지게 됩니다

### Client

- 최종적으로 이 팩토리와 Product 들을 사용하는 Client 클래스는 아래와 같이 구현할 수 있습니다

```ts
// Application.ts
import { Component } from './Component';
import { Sidebar, SidebarImpl } from './Sidebar';
import { Button, ButtonImpl } from './atomics/Button';
import {
  DndComponentFactory,
  MobileDndComponentFactory,
  WebDndComponentFactory,
  DndContainer,
  isMobileDevice,
} from './dnd';
import { bootstrapCss } from './style';

export class Application implements Component {
  public dndComponentFactory: DndComponentFactory<string>;
  public dndContainer: DndContainer<string>;

  constructor(public readonly root: () => HTMLElement) {
    this.dndComponentFactory = isMobileDevice() ? new MobileDndComponentFactory() : new WebDndComponentFactory();
    this.dndContainer = this.dndComponentFactory.createDndContainer(() => root().querySelector('.dnd-slot')!, {
      factory: this.dndComponentFactory,
      items: [
        { id: '1', data: 'hello' },
        { id: '2', data: 'world' },
        { id: '3', data: 'this' },
        { id: '4', data: 'is' },
        { id: '5', data: 'a' },
        { id: '6', data: 'dnd' },
        { id: '7', data: 'container' },
      ],
    });
  }

  template() {
    return `
      <div class="dnd-slot"></div>
      <div class="button-slot"></div>
    `;
  }

  render(): void {
    this.root().innerHTML = this.template();
    this.dndContainer.render();
    this.hydrate();
  }

  hydrate(): void {
    this.dndContainer.hydrate();
  }
}
```

- 아래와 같이 Client는 Application의 설정 또는 환경값에서 Mobile기기인지 판단하여 알맞은 Factory 객체를 인스턴스화하여 사용합니다
- 이때 dndComponentFactory 필드는 위에서 언급했듯 인터페이스 타입이기 때문에 구체적인 구현에 대해 의존하지 않습니다

```ts
    this.dndComponentFactory = isMobileDevice() ? new MobileDndComponentFactory() : new WebDndComponentFactory();
```

- 최종 클래스 구조도

```
DndContainer (Interface) - DndContainerImpl (Abstract Class)
|- WebDndContainer (Concrete Class)
|- TouchDndContainer (Concrete Class)

DndItem (Interface) - DndItemImpl (Abstract Class)
|- WebDndItem (Concrete Class)
|- TouchDndItem (Concrete Class)

Indicator (Interface)
|- IndicatorImpl (Concrete Class)

DndComponentFactory (Interface)
|- WebDndComponentFactory (Concrete Class)
|- TouchDndComponentFactory (Concrete Class)

Application
|- DndComponentFactory
|- DndContainer
    |- DndItem
        |- DndIndicator
```

## Discussion

### Factory 인스턴스화

- Factory 를 Concrete Product 클래스들의 생성자에 파라미터로서 전달하는 구조로 구현합니다
- Dependency Injection 을 생각하면 이 방법이 최선인 것 같은데..
- Concrete Product 클래스 내부에서 인스턴스화 하는 코드가 들어가면 어떤 단점이 발생할까?
- ref: [위키피디아 - 의존성 주입](https://ko.wikipedia.org/wiki/%EC%9D%98%EC%A1%B4%EC%84%B1_%EC%A3%BC%EC%9E%85)
    - 위 문서에서는 `클래스는 더 이상 객체 생성에 대한 책임이 없으며, 추상 팩토리 디자인 패턴에서처럼 팩토리 객체로 생성을 위임할 필요가 없습니다.` 라는 설명이 있습니다

## Wrap Up
추상 팩토리 패턴은 Creational Patterns에 속하는 디자인 패턴입니다. 원문에서 다룬 문제 상황, 해결 구조, TypeScript 예제를 중심으로 핵심 흐름을 정리했습니다.

### Summary
추상 팩토리 패턴은 관련 객체들의 구상 클래스에 직접 의존하지 않고 제품군을 생성하는 방법을 다룹니다. 원문 코드와 용어 설명을 최대한 유지하여 패턴의 의도와 적용 지점을 함께 확인할 수 있도록 구성했습니다. 실제 적용 시에는 클라이언트 코드가 구상 클래스에 직접 의존하는 정도, 책임이 한 클래스에 몰리는 정도, 런타임에 조합이 필요한지 여부를 함께 살펴보는 것이 좋습니다.

### Reference
- [Refactoring.guru](https://refactoring.guru/)
