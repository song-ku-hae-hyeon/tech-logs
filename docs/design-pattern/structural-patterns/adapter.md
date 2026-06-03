---
title: 어댑터 패턴
description: 어댑터 패턴은 호환되지 않는 인터페이스를 가진 객체들이 함께 동작하도록 인터페이스를 변환하는 구조 패턴입니다.
sidebar_position: 1
tags:
  - design-pattern
---

> 어댑터는 호환되지 않는 인터페이스를 가진 객체들이 협업할 수 있도록 하는 구조적 디자인 패턴입니다.

## Terminology

- Client: 프로그램의 기존 비즈니스 로직을 포함하는 클래스, 우리가 작성하는 클래스가 됩니다
- Client Interface: 다른 클래스들이 클라이언트 코드와 공동 작업할 수 있도록 따라야 하는 프로토콜, 공통의 동작을 정의합니다
- Service: 타사 또는 레거시의 유용한 클래스, 호환성을 위해 Client Interface를 거쳐 사용해야 합니다
- Adapter: 클라이언트와 서비스 양쪽에서 작동할 수 있는 클래스, 클라이언트 인터페이스를 구현하여 서비스 객체를 래핑합니다

## Overview

- Wrapper 패턴으로도 불리며, `어댑터`는 한 객체의 인터페이스를 다른 객체가 이해할 수 있도록 변환하는 객체를 의미합니다
- 구현체로서는 `객체 어댑터`, `클래스 어댑터` 두가지가 존재

### 객체 어댑터

- `합성`을 사용하는 구현합니다
- `어댑터`는 한 객체의 인터페이스를 구현하고, 다른 객체는 래핑합니다
```ts
/**
 * 직접 컨트롤할수 없는 서드파티 라이브러리 등의 객체
 * 서드파티 라이브러리가 아니더라도, 형식이 맞지 않는 다른 어떠한 클래스도 여기에 해당될 수 있습니다
 * 예시로서는 숫자를 받아 10을 더해 특정 포맷으로 출력하는 기능을 제공
 */
class Service {
  public method(data: number) {
    console.log(`${data} + 10 = ${data + 10}`);
  }
}

/**
 * 다른 클래스들이 클라이언트와 공동 작업할 수 있도록 하는 공통의 구조
 * 예시로서 숫자 대신 문자열을 전달해야 동작 가능하도록 어댑터 클래스를 구현할 것입니다
 */
interface IClient {
  method(data: string): void;
}

/**
 * 클라이언트와 클래스 양쪽에서 사용가능한 클래스
 * 서비스 객체를 래핑하며 클라이언트 인터페이스를 구현
 */
class Adapter implements IClient {
  service: Service = new Service();

  public method(data: string) {
    if (typeof data === 'number') return this.service.method(data);
    const convertedData = parseInt(data);
    this.service.method(convertedData);
  }
}

/**
 * Adapter 클래스를 실제로 사용하는 Client 객체
 * 하지만 구상 클래스 Adapter 가 아닌 인터페이스 IClient 에 의존함
 */
class Client {
  some: IClient = new Adapter();

  public static main() {
    const client = new Client();
    client.some.method("4"); // 4 + 10 = 14
  }
}

Client.main();
```

### 클래스 어댑터

- `상속` 을 사용하는 구현합니다
- 언어 디자인이 `다중 상속`을 허용해야 합니다
- `어댑터` 클래스가 `클라이언트 인터페이스`를 구현하며 내부에 `서비스` 객체를 가지지 않습니다
- `어댑터` 클래스는 `서비스` 객체와 다른 객체를 동시에 상속받아 사용됩니다

> 다중 상속을 허용하는 언어들:
> C++, Python, Perl, Eiffel, Common Lisp, Dylan, Tcl, Lua - by ChatGPT

- 타입스크립트는 다중 상속을 지원하지 않아 가장 신택스가 비슷한(아마도) C++ 로 작성

```c++
#include <iostream>
#include <string>

/**
 * 서드파티 라이브러리에서 제공하는 클래스
 * 메소드의 파라미터는 int 타입
 */
class Service {
public:
    void special_method(int special_data) {
        std::cout << special_data << " + 10 = " << special_data + 10 << std::endl;
    }
};

/**
 * 우리 애플리케이션의 클래스
 * 메소드의 파라미터는 문자열 타입
 */
class ExistingClass {
public:
    void method(std::string data) {
        int i_data = std::stoi(data);
        std::cout << data << " + 10 = " << i_data + 10 << std::endl;
    }
};

/**
 * 기존 ExistingClass의 메소드를 오버라이드하여 Service 클래스를 문자열 타입도
 * 사용가능하도록 만들어줌
 */
class Adapter : public Service, public ExistingClass {
public:
    void method(int data) {
        Service::special_method(data);
    }

    // 실제 Adaptation이 발생하는 오버라이드된 메소드
    void method(std::string data) {
        int special_data = std::stoi(data);
        Service::special_method(special_data);
    }
};

class Client {
private:
    ExistingClass* _ec;

public:
    Client(ExistingClass* ec) : _ec(ec) {}
    ~Client() { delete this->_ec; }

    void main() {
        this->_ec->method("4"); // 4 + 10 = 14
    }
};

int main() {
    // ExistingClass 타입에 Adapter 클래스 할당 가능
    Client* client = new Client(new Adapter());
    client->main();
    delete client;
}
```

## 유즈케이스 - api wrapping

- 칸반보드 형태의 투두리스트 앱
- 이때 [supabase](https://supabase.com/) 데이터베이스를 사용하여 앱의 백엔드를 지원한다면

```ts
// src/Kanban/infrastructure/repository.ts
// Service 클래스
// 우리가 통제할 수 없는 인터페이스
export const supabaseClient: SupabaseClient = createClient(
  import.meta.env.VITE_SUPABASE_URL as string,
  import.meta.env.VITE_SUPABASE_KEY as string,
  { auth: { storage: window.localStorage } }
);

// Client interface
// SupabaseClient 타입 객체를 우리 애플리케이션에서 사용할 수 있도록 어댑터의 역할을 함
export interface ColumnRepositoryAdapter {
  save(column: ColumnDto): Promise<void>;
  saveAll(columns: ColumnDto[]): Promise<void>;
  find(id: string): Promise<ColumnDto | null>;
  findAll(): Promise<ColumnDto[]>;
  findAllWithCards(): Promise<(ColumnDto & { cards: CardDto[] })[]>;
}

// Adapter 클래스
// 우리가 사용할 포맷을 따르는 객체, 내부에 Service 클래스를 가지고 사용할 수 있는 형태로 바꿔줌
export class ColumnRepositoryAdapterImpl implements ColumnRepositoryAdapter {
  private client: SupabaseClient = supabaseClient;
  // ...

  public async save(column: ColumnDto) {
    // ...
  }

  public async saveAll(columns: ColumnDto[]) {
    // ...
  }

  public async find(id: string) {
    // ...
  }

  public async findAll() {
    // ...
  }

  public async findAllWithCards() {
    const result = await this.client.from(this.tableName).select(`
      id,
      name,
      cards: "${this.cardsTableName}" (*)
    `);
    if (result.error) throw result.error;
    return result.data as (ColumnDto & { cards: CardDto[] })[];
  }
}

// src/Kanban/domain/Column.ts
// 클라이언트 클래스
// Adapter 클래스에 해당하는 ColumnRepositoryAdapterImpl 클래스를 실제로 사용하는 코드
export class ColumnService {
  private readonly repository: ColumnRepositoryAdapter = new ColumnRepositoryAdapterImpl();

  public async save(column: Column) {
    // ...
  }

  public async saveAll(columns: Column[]) {
    // ...
  }

  public async find(name: string) {
    // ...
  }

  public async findAll() {
    // ...
  }

  public async findAllWithCards() {
    const columns = await this.repository.findAllWithCards();
    return columns.map(column => ({
      ...column,
      cards: column.cards.map(Card.fromDto),
    }));
  }
}
```

- Full code reference: https://github.com/rudy3091/app

## Discussion

### 어댑터 클래스는 메소드 구조는 똑같고, 세부 인터페이스만 다르게 작성해야 하는가?

- 일단은 그렇지 않다고 생각중
- ref: [nestjs의 AbstractHttpAdapter](https://github.com/nestjs/nest/blob/master/packages/core/adapters/http-adapter.ts#L12)는 express와 fastify의 전혀 다른 api를 하나로 통합
- ref2: [axios의 adapter](https://github.com/axios/axios/tree/v1.x/lib/adapters)는 `node:http` 모듈과 `xhr` 의 인터페이스를 하나로 통합
- 엄밀하게 객체지향의 관점에서 따졌을 때에도 적절한 예시인지?

## Wrap Up
어댑터 패턴은 Structural Patterns에 속하는 디자인 패턴입니다. 원문에서 다룬 문제 상황, 해결 구조, TypeScript 예제를 중심으로 핵심 흐름을 정리했습니다.

### Summary
어댑터 패턴은 호환되지 않는 인터페이스를 가진 객체들이 함께 동작하도록 인터페이스를 변환하는 구조 패턴입니다. 원문 코드와 용어 설명을 최대한 유지하여 패턴의 의도와 적용 지점을 함께 확인할 수 있도록 구성했습니다. 실제 적용 시에는 클라이언트 코드가 구상 클래스에 직접 의존하는 정도, 책임이 한 클래스에 몰리는 정도, 런타임에 조합이 필요한지 여부를 함께 살펴보는 것이 좋습니다.

### Reference
- [Refactoring.guru](https://refactoring.guru/)
