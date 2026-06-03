---
title: 메멘토 패턴
description: 메멘토 패턴은 객체의 캡슐화를 깨지 않고 이전 상태를 저장하고 복원하는 행동 패턴입니다.
sidebar_position: 2
tags:
  - design-pattern
---

> 메멘토는 객체의 구현 세부 사항을 공개하지 않으면서 해당 객체의 이전 상태를 저장하고 복원할 수 있게 해주는 행동 디자인 패턴입니다.

## 의미

### 배경

- 텍스트 편집기와 같은 앱을 만든다고 가정합니다. 오늘 날의 사용자들은 실행 취소 기능을 기대합니다. 이러한 작업이 수행되려면 어떤 작업을 수행하기 전에 모든 객체의 상태를 기록하여 저장해야 합니다. 사용자가 실행 취소를 하기로 결정하면 가장 최신 스냅샷을 가져와 모든 객체를 복원합니다.

- 위 기능을 수행하려면 클래스 내부의 세부 정보를 모두 공개해야 하는 상황이 됩니다. (텍스트, 커서 좌표, 스크롤 위치 등) 만약 클래스의 상태에 접근하지 못하면 스냅샷을 생성하기 어렵습니다.

### 해결

- 메멘토는 상태 스냅샷들의 생성을 해당 상태의 실제 소유자인 Originator 객체에 위임합니다. 위의 상황에 대입하면, 자신의 상태에 완전한 접근 권한이 있는 편집기 클래스가 자체적으로 스냅샷을 생성할 수 있도록 합니다.

- 이 패턴은 메멘토라는 특수 객체에 객체 상태의 복사본을 저장하라고 제안합니다. 메멘토의 내용에는 메멘토를 생성한 객체를 제외한 어떤 객체도 접근할 수 없습니다.

### 구조

<img width="586" alt="image" src="https://github.com/song-ku-hae-hyeon/Dive-into-Design-Pattern/assets/71266602/3fdec86d-3096-4329-8d8f-5ffba33975f2" />
- Caretaker 라는 객체에 메멘토(스냅샷)들을 저장할 수 있습니다. 케어테이커는 제한된 인터페이스를 가지므로 메멘토 상태를 변경할 수 없으나 메타데이터는 볼 수 있습니다.
- Originator는 메멘토 내부의 모든 필드에 접근할 수 있으므로 언제든지 자신의 이전 상태를 복원할 수 있습니다.
- Originator는 자신의 기능 외에 스냅샷을 저장하는 기능(makeSnapshot)과 복원 기능 (restore)을 가지고 있음을 알 수 있습니다.

## 코드

- 사용자가 사각형이나 도형 등을 그릴 수 있는 간단한 어플리케이션이 있다고 가정합니다. 여러가지 도형을 그리고 이전 상태 복원도 가능해야 합니다.

### Shape

```ts
interface Shape {
    type: string;
    x: number;
    y: number;
    toString(): string;
}

class Circle implements Shape {
    type: string = 'circle';
    constructor(public x: number, public y: number, public radius: number) {}

    toString(): string {
        return `Circle at (${this.x}, ${this.y}) with radius ${this.radius}`;
    }
}

class Rectangle implements Shape {
    type: string = 'rectangle';
    constructor(public x: number, public y: number, public width: number, public height: number) {}

    toString(): string {
        return `Rectangle at (${this.x}, ${this.y}) with width ${this.width} and height ${this.height}`;
    }
}
```
- 원과 사각형 클래스를 만듭니다. 그리는 것 대신에 예시 코드를 확인할 수 있도록 `toString`을 주어 출력 가능하도록 만들었습니다.

### Memento

```ts
interface Memento {
    getState(): Shape[];
    getName(): string;
    getDate(): string;
}

class ConcreteMemento implements Memento {
    private state: Shape[];
    private date: string;

    constructor(state: Shape[]) {
        this.state = state;
        this.date = new Date().toISOString().slice(0, 19).replace('T', ' ');
    }

    public getState(): Shape[] {
        return this.state;
    }

    public getName(): string {
        return `${this.date} / (${this.state.length} shapes)`;
    }

    public getDate(): string {
        return this.date;
    }
}
```
- 메멘토 인터페이스를 작성합니다. `getState`를 보면 도형 배열이 들어 있습니다. 특정 시점에 그려진 도형들을 의미합니다. `getName`, `getDate`로 메타데이터도 제공합니다

### Originator
- 여기서의 Originator는 그림판 혹은 캔버스 등이 될 수 있습니다. (예제이므로 콘솔로그로 대체.)

```ts
class Originator {
    private shapes: Shape[] = [];

    addShape(shape: Shape): void {
        this.shapes.push(shape);
        console.log(`Shape added: ${shape.type} at (${shape.x}, ${shape.y})`);
    }

    getShapes(): Shape[] {
        return this.shapes;
    }

    saveStateToMemento(): Memento {
        return new ConcreteMemento([...this.shapes]);
    }

    getStateFromMemento(memento: Memento): void {
        this.shapes = memento.getState();
        console.log('State restored from Memento');
    }

    printShapes(): void {
        console.log('Current Shapes:', this.shapes.map(shape => shape.toString()));
    }
}
```

- addShape로 도형이 추가될 때마다 배열에 넣어줌. 이들은 `printShapes` 로 출력하여 볼 수 있습니다
- `saveStateToMemento` 로 스냅샷을 저장할 수 있고, `getStateFromMemento` 로 복원할 수 있습니다.

### Caretaker

- 스냅샷들을 관리해주는 Caretaker

```ts
class Caretaker {
    private mementos: Memento[] = [];
    private originator: Originator;

    constructor(originator: Originator) {
        this.originator = originator;
    }

    backup(): void {
        console.log('\nCaretaker: Saving Originator\'s state...');
        this.mementos.push(this.originator.saveStateToMemento());
    }

    undo(): void {
        if (!this.mementos.length) {
            return;
        }
        const memento = this.mementos.pop();
        console.log(`Caretaker: Restoring state : ${memento.getName()}`);
        this.originator.getStateFromMemento(memento);
    }

    showHistory(): void {
        console.log('Caretaker: Here\'s the list of mementos:');
        for (const memento of this.mementos) {
            console.log(memento.getName());
        }
    }
}
```
- originator를 받도록 되어있으며, `backup` 시 오리지네이터를 통해 스냅샷을 저장. `undo`시 메멘토를 꺼내어 originator가 복원하도록 지시.

### Use
```ts
const originator = new Originator();
const caretaker = new Caretaker(originator); 

// Add shapes and create backups
originator.addShape(new Circle(10, 10, 5)); // Shape added: circle at (10, 10)
caretaker.backup(); // Caretaker: Saving Originator's state...

originator.addShape(new Rectangle(20, 20, 10, 15)); // Shape added: rectangle at (20, 20)
caretaker.backup(); // Caretaker: Saving Originator's state...

originator.addShape(new Circle(30, 30, 10)); // Shape added: circle at (30, 30)
caretaker.backup(); // Caretaker: Saving Originator's state...

caretaker.showHistory();
/**
Caretaker: Here's the list of mementos:
2024-05-10 12:00:00 / (1 shapes)
2024-05-10 12:02:30 / (2 shapes)
2024-05-10 12:07:02 / (3 shapes)
 */

originator.printShapes(); // Current Shapes: [ 'Circle at (10, 10) with radius 5', 'Rectangle at (20, 20) with width 10 and height 15', 'Circle at (30, 30) with radius 10' ]


caretaker.undo(); // Caretaker: Restoring state : 2024-05-10 12:07:02 / (3 shapes)
originator.printShapes(); // Current Shapes: [ 'Circle at (10, 10) with radius 5', 'Rectangle at (20, 20) with width 10 and height 15' ]

caretaker.undo(); // Caretaker: Restoring state : 2024-05-10 12:02:30 / (2 shapes)
originator.printShapes(); // Current Shapes: [ 'Circle at (10, 10) with radius 5' ]
```

## 장단점

### 장점

- 이전 상태를 복원할 수 있도록 객체의 스냅샷을 생성하는 경우에 유용합니다.
- 캡슐화를 위반하지 않고 객체 상태의 스냅샷들을 생성할 수 있습니다.
- 케어테이커가 상태 기록을 유지하도록하여 오리지네이터의 코드를 단순화할 수 있습니다.

### 단점

- 클라이언트들이 메멘토를 자주 생성하면 앱이 많은 RAM을 소모할 수 있습니다.
- 케이테이커들이 더 이상 쓸모없는 메멘토들을 제거할 수 있도록 오리지네이터의 수명주기를 추적해야 합니다.
- JS와 같은 동적 프로그래밍 언어에서 메멘토 내의 상태가 그대로 유지된다고 보장할 수 없습니다.

## Wrap Up
메멘토 패턴은 Behavioral Patterns에 속하는 디자인 패턴입니다. 원문에서 다룬 문제 상황, 해결 구조, TypeScript 예제를 중심으로 핵심 흐름을 정리했습니다.

### Summary
메멘토 패턴은 객체의 캡슐화를 깨지 않고 이전 상태를 저장하고 복원하는 행동 패턴입니다. 원문 코드와 용어 설명을 최대한 유지하여 패턴의 의도와 적용 지점을 함께 확인할 수 있도록 구성했습니다. 실제 적용 시에는 클라이언트 코드가 구상 클래스에 직접 의존하는 정도, 책임이 한 클래스에 몰리는 정도, 런타임에 조합이 필요한지 여부를 함께 살펴보는 것이 좋습니다.

### Reference
- [Refactoring.guru](https://refactoring.guru/)
