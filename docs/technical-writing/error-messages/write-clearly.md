---
title: Write Clearly
description: 에러메시지를 명확히 작성하는 방식을 다룹니다.
sidebar_position: 2
tags:
  - technical-writing
---

## Be concise

- 에러 메시지를 간결하게 작성합니다.
  - 무엇이 중요한지 강조
  - 불필요한 텍스트 제거
  - DB로의 연결 실패 예시 :
    :::danger[bad]
    Unable to establish connection to the SQL database.
    :::
    :::tip[good]
    Can’t connect to the SQL database.
    :::
  - 클러스터 내에 리소스가 존재하지 않는 경우 예시 :
    :::danger[bad]
    The resource was not found and cannot be differentiated. What you selected doesn’t exist in the cluster.
    :::
    :::tip[good]
    Resource name isn’t in cluster name
    :::
- 수동태를 능동태로 바꾸면 더 간결하고 이해하기 쉬운 문장을 만들 수 있습니다.
  - App이 더이상 특정 연산자를 지원하지 않음 예시 :
    :::danger[bad]
    The Froobus operation is no longer supported by the Frambus app.
    :::
    :::tip[good]
    The Frambus app no longer supports the Froobus operation.
    :::
- 너무 과하게 단어를 줄이면 에러 메시지는 암호처럼 느껴집니다.
  - 무엇을 지원하지 않는지 알 수 없을 경우 예시 :
    :::danger[bad]
    Unsupported
    :::

## Avoid double negatives

- 독자들은 이중 부정을 이해하기 어려워합니다.
  - 예시 :
    :::danger[bad]
    You cannot not invoke this flag.
    :::
    :::tip[good]
    You must invoke this flag.
    :::
- 더 미묘한 이중 부정도 있습니다.
  - prevents와 forbidding이 부정의 의미로 사용된 예시 :
    :::danger[bad]
    The universal read permission on pathname prevents the operating system from forbidding access.
    :::
    :::tip[good]
    The universal read permission on pathname enables anyone to read this file. Giving access to everyone is a security flaw. See hyperlink for details on how to restrict readers.
    :::
- 예외의 또 다른 예외를 만드는 것을 피합니다.
  - 예시 :
    :::danger[bad]
    The App Engine service account must have permissions on the image, except the Storage Object Viewer role, unless the Storage Object Admin role is available.
    :::
    :::tip[good]
    The App Engine service account must have one of the following roles : - Storage Object Admin - Storage Object Creater
    :::

## Write for the target audience

- 에러 메시지를 대상 독자에게 맞춥니다 :
  - 적절한 용어 사용
  - 대상 독자가 아는 것과 모르는 것을 염두하자
- 다음 메시지는 ML 전문가에게만 적절하다.
  - “Exploding gradient problem. To fix this problem, consider gradient clipping”
- 온라인 쇼핑몰에 트래픽이 몰려 결재에 실패할 경우를 살펴보겠습니다.
  - 기술적 지식이 없는 접속자는 아래의 메시지를 이해하기 어렵습니다.
    - “A server dropped your client’s request because the server farm is running at 92% CPU capacity. Retry in five minutes.”
  - 아래 메시지처럼 바꿔주면 좋을 것입니다.
    - “So many people are shopping right now that our system can’t complete your purchase. Don’t worry. we won’t lose your shopping cart. Please retry your purchase in five minutes.”

## Use terminology consistently

- 용어를 일관되게 사용합니다.
  :::danger[bad]
  Can’t connect to cluster at 127.0.0.1:56. Check whether minikube is running.
  :::
  :::tip[good]
  Can’t connect to minikube at 127.0.0.1:56. Check whether minikube is running.
  :::
- 에러 메시지에 일관된 형식과 모순되지 않은 내용이 나타나야 합니다.
  - 같은 문제에는 같은 에러 메시지가 발생합니다.

## Format error messages to enhance readability

- 긴 설명이 필요하다면, 자세한 문서 링크로 유저를 리다이렉트 해줍니다.
  :::danger[bad]
  Post contains unsafe information.
  :::
  :::tip[good]
  Post contains unsafe information. Learn more about safety at link to documentation.
  :::
- 유저는 때때로 긴 에러 메시지를 무시합니다. 간결한 버전의 에러 메시지를 보여주고, 전체 내용을 볼 수 있는 옵션을 제공합니다.
  :::danger[bad]
  TextField widgets require a Material widget ancestor, but none were located. In material design, most widgets are conceptually “printed” on a sheet of material. To introduce a Material widget, either directly include one or use a widget that contains a material itself.
  :::
  :::tip[good]
  TextField widgets require a Material widget ancestor, but none were located.
  …(Click to see more.)
  In material design, most widgets are conceptually “printed” on a sheet of material. To introduce a Material widget, either directly include one or use a widget that contains a material itself.
  :::
- 코드 에러는 가능한 에러가 발생한 곳에 에러 메시지를 위치합니다.

  :::danger[bad]

  ```
  1: program figure_1;
  2: Grade = integer;
  3: var
  4: print("Hello")
  Use ':' instead of '=' when declaring a variable
  ```

  :::
  :::tip[good]

  ```
  1: program figure_1;
  2: Grade = integer;
  Use ':' instead of '=' when declaring a variable
  3: var
  4: print("Hello")
  ```

  :::

- 놀랍게도 많은 독자들이 색맹이라, 색상을 사용할 때 조심해야합니다.

  - 빨간색/녹색 조합을 피합니다.
  - **볼드체**를 함께 사용합니다.
  - 컬러가 변환되는 구간에 여분의 스페이스를 추가합니다.
  - 색상 말고 다른 하이라이트 방법을 사용합니다.
    ```
    3728LJ947
        ^^
    ```

## Set the right tone

- 에러 메시지의 어조는 큰 영향을 미칠 수 있습니다.

### Be positive

- 잘못보다, 올바른 것이 무엇인지 말해줍니다.
  :::danger[bad]
  You didn’t enter a name.
  :::
  :::tip[good]
  Enter a name.
  :::

### Don’t be overly apologetic

- 긍정적인 태도를 유지하며 “sorry” 혹은 “please” 단어를 피합니다.
- 문제와 해결책을 명확히 설명하는데에 집중합니다.
- 참고: 문화마다 사과를 다르게 해석할 수 있기에, 타겟이 되는 고객의 기대에 유의합니다.
  :::danger[bad]
  We’re sorry, a server error occurred and we’re temporarily unable to load your spreadsheet. We apologize for the inconvenience. Please wait a while and try again.
  :::
  :::tip[good]
  Google Docs is temporarily unable to open your spreadsheet. In the meantime, try right-clicking the spreadsheet in the doc list to download it.
  :::

### Avoid humor

- 에러 메시지를 유머스럽게 작성하지 않습니다.
  :::danger[bad]
  Is the server running? Better go catch it :D.
  :::
  :::tip[good]
  The server is temporarily unavailable. Try again in a few minutes.
  :::

### Don’t blame the user

- 오류의 책임을 부여하기 보다는 무엇이 잘못되었는지 집중합니다.
  :::danger[bad]
  You specified a printer that’s offline.
  :::
  :::tip[good]
  The specified printer is offline.
  :::
