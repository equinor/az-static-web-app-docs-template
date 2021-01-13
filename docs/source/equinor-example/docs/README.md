Thanks to the [Omnia team](https://docs.omnia.equinor.com/) for this template.

## Diagrams using mermaid

The docs support diagrams using [mermaid](https://mermaid-js.github.io/mermaid/#/).

Diagrams can easily be made using the diagram notation. For example the following lines of markdown:

````
```mermaid
graph TD;
    A-->B;
    A-->C;
    B-->D;
    C-->D;
```
````

produces

```mermaid
graph TD;
    A-->B;
    A-->C;
    B-->D;
    C-->D;
```

View the mermaid docs for more diagram examples.

## Math expressions

Math expressions can be created using the Latex notation:

```
$$
\operatorname{ker} f=\{g\in G:f(g)=e_{H}\}{\mbox{.}}
$$
```

Which gives the following expression:

$$
\operatorname{ker} f=\{g\in G:f(g)=e_{H}\}{\mbox{.}}
$$