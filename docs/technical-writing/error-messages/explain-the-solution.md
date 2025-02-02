---
title: Expalin the solution
description: 오류 메시지에서 문제 해결 방법을 설명하는 방법에 대해 다룹니다.
sidebar_position: 2
tags:
  - technical-writing
---

## Explain how to fix the problem

실질적인 문제 해결을 돕는 오류 메시지를 작성합니다. 
즉, 문제 원인을 설명한 후에 문제 해결 방법을 설명합니다.

### Examples

다음은 앱 업데이트 필요성을 설명하는 예시입니다:

:::danger[Not recommended]
The client app on your device is no longer supported.
:::

:::tip[Recommended]
The client app on your device is no longer supported. To update the client app, click the Update app button.
:::

<br />


## Provide examples

문제 해결 방법을 설명하는 예시로 설명을 보충합니다.

### Examples

다음은 잘못된 이메일 형식을 설명하는 예시입니다:

:::danger[Not recommended]
Invalid email address.
:::

:::tip[Recommended]
The specified email address (robin) is missing an @ sign and a domain name. 

For example: robin@example.com.
:::

<br />

다음은 실행 파일 경로 입력 오류를 설명하는 예시입니다:

:::danger[Not recommended]
Invalid input.
:::

:::tip[Recommended]
Enter the pathname of a Windows executable file. An executable file ordinarily ends with the .exe suffix. 

For example: C:\Program Files\Custom Utilities\StringFinder.exe
:::

<br />

다음은 초기화 리스트의 타입 선언 오류를 설명하는 예시입니다:

:::danger[Not recommended]
Do not declare types in the initialization list.
:::

:::tip[Recommended]
Do not declare types in the initialization list. Use calls instead, such as 'BankAccount(owner, IdNum, openDate)' rather than 'BankAccount(string owner, string IdNum, Date openDate)'
:::

<br />

다음은 조건문의 괄호 누락 오류를 설명하는 예시입니다:

:::danger[Not recommended]
Syntax error on token "||", "if" expected.
:::

:::tip[Recommended]
Syntax error in the "if" condition. The condition is missing an outer pair of parentheses. Add a pair of bounding opening and closing parentheses to the condition.

For example:
```js
// Incorrect
if (a > 10) || (b == 0)

// Correct  
if ((a > 10) || (b == 0))
```
:::

## Wrap up

오류 메시지에서 해결책을 효과적으로 설명하는 방법을 알아보았습니다.  
해결 방법을 설명할 때는 다음과 같은 핵심 원칙을 기억하세요:

- 구체적이고 실행 가능한 해결 단계를 제시합니다.
- 해결 방법 관련한 예시를 제공합니다.

### Summary
오류 메시지는 사용자가 실제로 문제를 해결할 수 있도록 구체적인 가이드를 제공해야 합니다.  
단순히 문제를 설명하는 것에서 그치지 않고, 실행 가능한 해결 방법과 예시를 통해 사용자를 안내하는 것이 중요합니다.  
이를 통해 사용자는 오류를 더 쉽게 이해하고 해결할 수 있습니다.

### References
- [Google Tech Writing Error Messages Course- Explain the solution](https://developers.google.com/tech-writing/error-messages/show-fix)
