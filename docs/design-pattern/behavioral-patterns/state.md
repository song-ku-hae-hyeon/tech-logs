---
title: 상태 패턴
description: 상태 패턴은 객체 내부 상태가 바뀔 때 행동도 함께 바뀌도록 상태별 로직을 분리하는 행동 패턴입니다.
sidebar_position: 4
tags:
  - design-pattern
---

> 상태 패턴은 객체의 내부 상태가 변경될 때 해당 객체가 그의 행동을 변경할 수 있도록 하는 행동 디자인 패턴입니다.

## Overview

- 상태 패턴은 `Finite state machine(유한 상태 머신)` 개념과 밀접하게 연관되어 있다
    - '특정 시간에 프로그램이 속해 있을 상태의 갯수는 유한하다' 가 핵심 개념
    - 어떤 고유한 상태 내에서 프로그램은 다르게 행동합니다
    - 프로그램의 현재 상태에 따라 특정 다른 상태로 전환되거나 전환되지 않을 수 있습니다
    - 이때 상태의 전환을 `Transition(전이)` 이라 부릅니다
- 일반적으로 if/switch 문을 이용해 각 상태에 대한 로직을 구현합니다
    - 하지만 클래스에 상태에 의존하는 행동을 추가할수록 단점 발생합니다
    - 클래스의 메소드 대부분에 거대한 조건문이 들어가게 됩니다
    - 유지보수가 어려워짐
- 상태 패턴은 객체의 가능한 상태에 대해 클래스를 만들고, 모든 상태별 행동들을 이러한 클래스로 추출하는 것을 제안합니다
    - `Context` 라는 객체가 상태를 매니징하는 역할을 합니다
    - Context 객체는 모든 행동을 직접 구현하지 않습니다
    - 대신 상태 객체에 대한 참조를 가지고, 실제 작업은 상태 객체에 위임합니다

## Terminology

- Context: Concrete state 중 하나에 대한 참조를 저장하고, 모든 State 별 작업을 이곳에 위임합니다
    - State 인터페이스를 통해 State 객체와 통신합니다
    - State 객체 변경을 위한 세터 메소드를 노출
- State: 상태별 메소드들을 선언하는 인터페이스
    - 이 메소드들은 모든 Concrete state 에서 호출가능해야 합니다
- Concrete state: 상태별 메소드들에 대한 자체적인 구현을 제공합니다
    - 중간 레이어의 추상화된 클래스 구현으로 상태간 중복을 줄일 수도 있습니다

 > Context 객체가 Concrete state 객체들의 참조를 저장하고 있지만, Concrete state 객체들도 상태의 전이를 위해 Context 객체의 역참조를 가질 수 있습니다.

## Implementation

```ts
// Context class
// state에 대한 참조를 가지며, 실제 동작은 state 에 위임
class Context {
  private state!: State;

  public setState(state: State): void {
    this.state = state;
  }

  public actionA(): void {
    this.state.actionA();
  }

  public actionB(): void {
    this.state.actionB();
  }
}

// State interface
// 상태별 메소드들을 정의하는 인터페이스
interface State {
  actionA(): void;
  actionB(): void;
}

// Concrete state class
// 상태별 메소드들의 자체적인 구현 제공
class StateA implements State {
  constructor(private context: Context) {}

  public actionA(): void {
    console.log("action A");
  }

  public actionB(): void {
    // does nothing
  }
}

class StateB implements State {
  constructor(private context: Context) {}

  public actionA(): void {
    // does nothing
  }

  public actionB(): void {
    console.log("transition to state A");
    this.context.setState(new StateA(this.context));
  }
}

class Application {
  private context: Context;

  constructor() {
    this.context = new Context();
    this.context.setState(new StateB(this.context));
  }

  public run(): void {
    this.context.actionA();
    this.context.actionB();
    this.context.actionA();
  }

  static main(): void {
    const app = new Application();
    app.run();
  }
}

Application.main();
// output:
// transition to state A
// action A
```

## Usecases

### Audio player 예제

```ts
class Player {
  private state: State;

  time: number = 0;
  track: number = 0;
  paused: boolean = false;
  playButton: HTMLButtonElement;
  ui: HTMLInputElement;
  intervalId: NodeJS.Timeout | null = null;

  constructor(playButton: HTMLButtonElement, slider: HTMLInputElement) {
    this.playButton = playButton;
    this.ui = slider;
  }

  public setState(state: State): void {
    this.state = state;
  }

  public playOrPause(): void {
    this.state.playOrPause();
  }

  public next(): void {
    this.state.next();
  }

  public prev(): void {
    this.state.prev();
  }
}

interface State {
  playOrPause(): void;
  next(): void;
  prev(): void;
}

abstract class BaseState implements State {
  constructor(protected player: Player) {}

  public updateUIs(): void {
    this.player.playButton.textContent = this.player.paused ? "Play" : "Pause";
    this.player.ui.value = this.player.time.toString();
  }

  public abstract playOrPause(): void;

  public next(): void {
    this.player.track++;
    this.player.time = 0;
    this.updateUIs();
  }

  public prev(): void {
    if (this.player.time < 5) {
      this.player.track--;
      this.player.time = 0;
    } else {
      this.player.time = 0;
    }
    this.updateUIs();
  }
}

class PlayState extends BaseState implements State {
  constructor(player: Player) {
    super(player);
  }

  public playOrPause(): void {
    this.player.paused = true;
    this.player.setState(new PauseState(this.player));
    clearInterval(this.player.intervalId as NodeJS.Timeout);
    this.updateUIs();
  }
}

class PauseState extends BaseState implements State {
  constructor(player: Player) {
    super(player);
  }

  public playOrPause(): void {
    this.player.paused = false;
    this.player.setState(new PlayState(this.player));
    this.player.intervalId = setInterval(() => {
      this.player.time++;
      this.updateUIs();
    }, 1000);
  }
}

class Application {
  private player: Player;

  constructor() {
    const playButton = document.getElementById("play") as HTMLButtonElement;
    const nextButton = document.getElementById("next")!;
    const prevButton = document.getElementById("prev")!;
    const slider = document.getElementById("slider") as HTMLInputElement;

    this.player = new Player(playButton, slider);
    this.player.setState(new PauseState(this.player));

    const playOrPause = () => this.player.playOrPause();
    const next = () => this.player.next();
    const prev = () => this.player.prev();

    playButton.addEventListener("click", playOrPause);
    nextButton.addEventListener("click", next);
    prevButton.addEventListener("click", prev);
  }
}

new Application();
```

### When to use

- 상태에 따라 다르게 행동하는 객체가 있을 때, 상태들의 수가 많고 상태간 전이가 자주 발생할 때 사용합니다
- 클래스의 필드들의 현재 값들에 따라 클래스가 행동하는 방식을 변경하는 거대한 조건문들로 클래스가 오염될 때 사용합니다
- 유사한 상태들에 중복 코드와 조건문 기반 상태 머신의 전이가 많을 때 사용합니다

## Wrap Up
상태 패턴은 Behavioral Patterns에 속하는 디자인 패턴입니다. 원문에서 다룬 문제 상황, 해결 구조, TypeScript 예제를 중심으로 핵심 흐름을 정리했습니다.

### Summary
상태 패턴은 객체 내부 상태가 바뀔 때 행동도 함께 바뀌도록 상태별 로직을 분리하는 행동 패턴입니다. 원문 코드와 용어 설명을 최대한 유지하여 패턴의 의도와 적용 지점을 함께 확인할 수 있도록 구성했습니다. 실제 적용 시에는 클라이언트 코드가 구상 클래스에 직접 의존하는 정도, 책임이 한 클래스에 몰리는 정도, 런타임에 조합이 필요한지 여부를 함께 살펴보는 것이 좋습니다.

### Reference
- [Refactoring.guru](https://refactoring.guru/)
