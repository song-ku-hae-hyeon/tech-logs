---
title: 빌더 패턴
description: 빌더 패턴은 복잡한 객체 생성 과정을 단계별로 분리하여 같은 생성 절차로 다양한 표현을 만들 수 있게 합니다.
sidebar_position: 3
tags:
  - design-pattern
---

> 빌더는 복잡한 객체들을 단계별로 생성할 수 있도록 하는 생성 디자인 패턴입니다.

> 이 패턴을 사용하면 같은 제작 코드를 사용하여 객체의 다양한 유형들과 표현을 제작할 수 있습니다.

## 의미

### 배경

- 복잡한 객체를 단계별로 초기화하여 생성해야 하는 경우, 많은 매개변수를 받아야 할 수 있습니다. (생성자 함수가 매우 복잡합니다.)
- `car` 를 만들기 위한 클래스 `Car` 가 있다고 가정합니다.
- 나중에는 일반 자동차가 아닌 스포츠카, SUV 등을 만들고 싶어집니다. 매개변수양이 증가하거나 Class가 계속 확장되게 됩니다.

### 해결

- 객체 생성 코드만 추출된 별도의 객체 `builders`가 탄생합니다.
- `CarBuilder` 라는 빌더 인터페이스는 차를 만들기 위한 단계들이 각 메소드로 정리되어 있습니다.
- 이 단계들의 집합을 여러가지 방식으로 구현하는 스포츠카 빌더, SUV 빌더, 택시 빌더 등을 만들 수 있습니다.
- 필요에 따라 일련의 호출을 Director라는 별도의 클래스로 추출하고, 디렉터가 실행 순서를 정의할 수 있습니다.

## 구조

<img width="450" alt="image" src="https://github.com/song-ku-hae-hyeon/Dive-into-Design-Pattern/assets/71266602/81edc4aa-d953-4da1-af75-1e582ce3dcba" />
- Builder Interface : 모든 유형에 공통으로 적용되는 생성 단계가 선언되어 있습니다.

- Concrete Builders : 생성 단계들의 실질적인 구현이 제공됩니다. 위의 설명에서의 SUV 빌더, 택시 빌더 등이 해당됩니다.

- Products : Builder의 결과물.

- Director : 생성 단계들을 호출하는 순서를 정의합니다. 재사용이 용이하나 필수는 아닙니다.

- Client : 사용자. 빌더 객체를 디렉터에 연결시킴.

- 빌더 패턴은 다른 생성 패턴과 달리 공통 인터페이스를 따르지 않는 결과물을 생성할 수 있습니다. 즉 결과물의 인터페이스는 다를 수 있습니다. 

- 따라서 Director에 결과를 가져오는 메서드를 배치할 수는 없습니다. 결과물을 얻는 코드는 빌더에 정의되어 있어야 합니다. (디렉터는 특정 순서로 생성 단계들을 실행하는 책임만 있습니다. 결과적으로 빌더 패턴은 특정 순서나 설정대로 결과를 만드는데 유용합니다.)

## 코드

### Concept

```ts

interface Builder {
    producePartA(): void;
    producePartB(): void;
    producePartC(): void;
}

class Product1 {
  // ...
}

class Product2 {
  // ...
}

class ConcreteBuilder1 implements Builder {
    private product: Product1;

    constructor() {
        this.reset();
    }

    public reset(): void {
        this.product = new Product1();
    }

    public producePartA(): void {
        this.product.parts.push('PartA1');
    }

    public producePartB(): void {
        this.product.parts.push('PartB1');
    }

    public producePartC(): void {
        this.product.parts.push('PartC1');
    }

    public getProduct(): Product1 {
        const result = this.product;
        this.reset();
        return result;
    }
}

class ConcreteBuilder2 implements Builder {
  // ...
}


class Director {
    private builder: Builder;

    public setBuilder(builder: Builder): void {
        this.builder = builder;
    }

    public buildMinimalViableProduct(): void {
        this.builder.producePartA();
    }

    public buildFullFeaturedProduct(): void {
        this.builder.producePartA();
        this.builder.producePartB();
        this.builder.producePartC();
    }
}

const director = new Director();
const builder1 = new ConcreteBuilder1();
const builder2 = new ConcreteBuilder2();

director.setBuilder(builder1);
director.buildMinimalViableProduct();
const minimalProduct1 = builder1.getProduct()

director.buildFullFeaturedProduct();
const fullProduct1 = builder1.getProduct()


director.setBuilder(builder2);

director.buildFullFeaturedProduct();
const fullProduct2 = builder2.getProduct()

```

### Use Case

- 복잡한 UI 컴포넌트 혹은 데이터 구조, 테스트 케이스 등에 사용할 수 있을 것으로 보입니다.
- 모달을 생성하는 경우를 가정하여 코드 작성.
- 모달의 전체 형태는 유사

<img width="300" alt="image" src="https://github.com/song-ku-hae-hyeon/Dive-into-Design-Pattern/assets/71266602/8fc00b90-7765-4ddc-88d2-37ee08ad82d7" />
<img width="300" alt="image" src="https://github.com/song-ku-hae-hyeon/Dive-into-Design-Pattern/assets/71266602/35bf6e32-0d33-428b-a2b5-585447ee87ee" />
```tsx
// Builder Interface
interface ModalBuilder {
  addTitle(title: string): void;
  addContent(content: ReactNode): void;
  addFooter(onConfirm: () => void, onCancel: () => void): void;
}

// 최소한의 input만 받고 각 모달에 맞는 부수적인 작업은 빌더에게 위임.

class CreateModalBuilder implements ModalBuilder {
    private modal: CreateModal;

    constructor() {
        this.reset();
    }

    public reset(): void {
        this.modal = new CreateModal();
    }

    public addTitle(title: string): void {
        // 제목 넣고...
        // 폰트 수정하고...
        // 아래 divider line 도 추가하고...
    }

    public addContent(content: ReactNode): void {
        // 받은 폼 넣어주고...
        // 적절한 마진 넣어주고...
    }

    public addFooter(onConfirm: () => void, onCancel: () => void): void {
        // 적절한 버튼 추가하고...
        // 각각 핸들링 함수 추가하고...
        // 옵션 넣어주고...
    }

    public getModal(): CreateModal {
        const result = this.modal;
        this.reset();
        return modal;
    }
}

class DeleteModalBuilder implements ModalBuilder {
    private modal: DeleteModal;
    // ...
    public getModal(): DeleteModal {
        const result = this.modal;
        this.reset();
        return modal;
    }
}

class UpdateModalBuilder implements ModalBuilder {
    private modal: UpdateModal;
    // ...
    public getModal(): UpdateModal {
        const result = this.modal;
        this.reset();
        return modal;
    }
}

```

## 장단점

### 적용

- 결과물의 표현이 다양하여 세부사항이 다르지만 유사한 단계를 포함하여 생성될 경우에 사용합니다. 빌더 인터페이스에 생성 단계들을 정의하여 Concrete Builders(구상 빌더)를 사용하기 좋습니다.
- 복잡한 객체들을 생성해야 할 경우. 단계별로 생성할 수 있고, 일부 단계 실행을 연기할 수 있습니다. 게다가 미완성 결과물은 노출되지 않으므로 불완전한 결과를 방지할 수 있습니다.

### 장점

- 단계별로 생성하거나 단계를 연기할 수 있습니다.
- 다양한 결과물을 만들지만 생성 코드 재사용이 용이합니다.
- 단일 책임 원칙에 따라 비즈니스 로직에서 복잡한 생성 코드를 분리시킬 수 있습니다.

### 단점

- 패턴이 매우 다양한 클래스(특히 다양한 구상 빌더)들을 생성해야 하므로 코드의 전반적인 복잡성이 증가합니다.

## 논의

## Wrap Up
빌더 패턴은 Creational Patterns에 속하는 디자인 패턴입니다. 원문에서 다룬 문제 상황, 해결 구조, TypeScript 예제를 중심으로 핵심 흐름을 정리했습니다.

### Summary
빌더 패턴은 복잡한 객체 생성 과정을 단계별로 분리하여 같은 생성 절차로 다양한 표현을 만들 수 있게 합니다. 원문 코드와 용어 설명을 최대한 유지하여 패턴의 의도와 적용 지점을 함께 확인할 수 있도록 구성했습니다. 실제 적용 시에는 클라이언트 코드가 구상 클래스에 직접 의존하는 정도, 책임이 한 클래스에 몰리는 정도, 런타임에 조합이 필요한지 여부를 함께 살펴보는 것이 좋습니다.

### Reference
- [Refactoring.guru](https://refactoring.guru/)
