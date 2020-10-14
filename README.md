# Documentação Código Tempo Real

## Arquitetura	

Para facilitar a portabilidade do código de MATLAB para Python, o código em ambas as linguagens vai ter uma estrutura idêntica. No entanto em Python vai ser utilizado multi processamento. No entanto como se está a recorrer a objetos para compartimentar as várias  funcionalidades do código isto vai traduzir-se numa separação do código em sub-rotinas (no Python) no entanto tanto o nome como as funcionalidades vão (idealmente) manter-se inalteradas.

### MATLAB

O código em matlab  apresenta três modos de funcionamento:

1. dados gerados(sintéticos)
2. dados(reais) recolhidos para serem tratados offline
3. modo de tempo real, usando um USRP



#### Classes MATLAB

##### framework

Esta classe implementa um buffer circular. Apresenta três métodos. O construtor, um método de introdução de dados e um último de retirada de informação do buffer.

Este buffer circular recorre a um ponteiro que indica qual é o próximo índice em que se pode escrever. Para que ele seja circular usa-se a função mod que permite calcular o índice seguinte usando o um módulo em função do tamanho do buffer.

###### métodos (argumentos) função



framework(tamanho do buffer) instanciação do objecto. Inicializa o frame buffer e o ponteiro.

append(frame) Insere uma frame no buffer seguinte

get()	Retorna todo o conteúdo do buffer por ordem de inserção



###### prova de funcionamento

Correndo passo a passo podemos ver o vetor de índices a ser alterado por iteração e a frame a ser populada



**1ª iteração**

![image-20201014141254643](/home/duarte/.config/Typora/typora-user-images/image-20201014141254643.png)



**3ª iteração**

![image-20201014142012138](/home/duarte/.config/Typora/typora-user-images/image-20201014142012138.png)

![image-20201014142227394](/home/duarte/.config/Typora/typora-user-images/image-20201014142227394.png)



#### Funções MATLAB



##### [f,x,y] = fit_correct(d,x_past,y_past,a1,a2,debug)

###### argumentos

d (array)-> data to adjust

x_past (double)-> past x prediction

y_past (double)-> past y prediction

a1 -> present weight

a2 -> past weigth

debug(boolean) -> debug flag

###### retorno

f -> sinal corrigido

x -> novo x

y -> novo y

###### função/funcionamento

Tem o objetivo de aplicar o algoritmo de circle fitting HYPERSVD() aplicando ao resultado um filtro de memória do tipo :
$$
a_1*d_x(t) +a_2 * d_x(t-1)
$$
O mesmo tipo de filtro é utilizado para o valor de y.

 Após a aplicação do filtro o sinal passa pela função arc_correct para corrigir a posição do arco.



##### g = arc_correct(g,debug)

###### argumentos

g (array)-> data to correct

debug(boolean) -> debug flag

###### retorno

f -> sinal corrigido

x -> novo x

y -> novo y

###### função/funcionamento

Corrige os arcos complexos. Começa por calcular a posição e tamanho do arco. De seguida procede à rotação do arco centrando-o no primeiro e segundo quadrante.

![image-20201014135736352](/home/duarte/.config/Typora/typora-user-images/image-20201014135736352.png)



#### Memfilt

Este é o script principal no qual se chamam as funções descritas acima

Assenta no modo 1 de funcionamento da framework desenvolvida pelo prof JNV. Nesta gera-se um sinal aleatório. Que é decimado e enviado para o buffer circular.

A função fit_correct  utiliza as frames do buffer circular e aplica o Hyeprfix, o filtro de memória e o algoritmo de correção de arco.

