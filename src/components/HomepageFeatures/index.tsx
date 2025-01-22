import clsx from "clsx";
import Heading from "@theme/Heading";
import styles from "./styles.module.css";

type FeatureItem = {
  title: string;
  Svg: React.ComponentType<React.ComponentProps<"svg">>;
  description: React.ReactNode;
};

const FeatureList: FeatureItem[] = [
  {
    title: "Design Pattern",
    Svg: require("@site/static/img/design-pattern.svg").default,
    description: (
      <>22개의 디자인 패턴을 정리하고, 각 패턴별로 예제를 통해 학습합니다.</>
    ),
  },
  {
    title: "Technical Writing",
    Svg: require("@site/static/img/technical-writing.svg").default,
    description: (
      <>명확하고 이해하기 쉬운 기술 문서를 작성하는 방법에 대해 학습합니다.</>
    ),
  },
  {
    title: "Unit Test",
    Svg: require("@site/static/img/unit-test.svg").default,
    description: (
      <>
        단위 테스트에 대한 기본기를 다지고, 올바른 테스트 케이스를 작성하는
        방법을 학습합니다.
      </>
    ),
  },
];

function Feature({ title, Svg, description }: FeatureItem) {
  return (
    <div className={clsx("col col--4")}>
      <div className="text--center">
        <Svg className={styles.featureSvg} role="img" />
      </div>
      <div className="text--center padding-horiz--md">
        <Heading as="h3">{title}</Heading>
        <p>{description}</p>
      </div>
    </div>
  );
}

export default function HomepageFeatures(): React.ReactElement {
  return (
    <section className={styles.features}>
      <div className="container">
        <div className="row">
          {FeatureList.map((props, idx) => (
            <Feature key={idx} {...props} />
          ))}
        </div>
      </div>
    </section>
  );
}
