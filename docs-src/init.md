# <b> Hospede um Site Estático com Segurança </b>

- **Criador:** Ricardo Mourão Rodrigues Filho
- **Ano de Criação:** 2023
- **Email:** ricardomrf@al.insper.edu.br

## Introdução

A ideia principal dessa documentação é apresentar uma forma adequada de como hospedar um site estático no bucket S3 da AWS. Além disso, você precisa trazer segurança para o seu site, portanto, ensinamos o usuário a criar dois recursos importantes: API Gateway (Novo endpoint do seu site) e WAF(Verifica se as requisições mandadas são maliciosas). Analise a arquitetura abaixo para um melhor entendimento:

![](img/icon-elementos.png)

Observe cada uma das etapas abaixo:

:one: - O usuário bate no endpoint da API Gateway. (O bucket S3 gera seu próprio endpoint, entretanto, a ideia é que o cliente não tenha contato direto por ele) <br>
:two: - API Gateway identifica a requisição. <br>
:three: - API Gateway manda a solicitação para o filtro do WAF. <br>
:four: - Quando chega ao filtro o WAF verifica as regras do owasp top ten, informando se a requisação é ou não é maliciosa. <br>
:five: - Passando pelo filtro, o usuário tem acesso ao bucket S3. <br>
:six: - Consequentemente, ele retorna o site hospedado com a devida segurança. <br>

Observe que uma das ferramentas apontadas é uso do [terraform](https://developer.hashicorp.com/terraform/tutorials/aws-get-started/infrastructure-as-code), na qual ele é responsável em gerar a infraestrutura do nosso projeto. Sendo assim, tenha todos dos pré-requisitos e siga as etapas abaixo para hospedar seu site estático com segurança.

----------------------------------------------
## Pré-Requisitos
- [Conta na AWS com usuário IAM com permissões de Administrador](https://docs.aws.amazon.com/pt_br/powershell/latest/userguide/pstools-appendix-sign-up.html).

- Baixar terraform na sua máquina.    

---------------------------------------------- 
## Funcionalidades

Esta aplicação buscou escalabilidade em todas as implementações. Logo, caso o usuário queira apenas etapas específicas, seguem as possíveis metodologias:

1. [Hospedagem de Site Estático](hostedS3.md) **(Entrega Completa C+)**
2. [API Gateway como Proxy para Site Estático](apiProxy.md) **(Entrega Completa B)**
3. [Proteção da Aplicação com WAF (Owasp Top Ten)](waf.md) **(Entrega Completa A+)**

!!! warning 
    É fundamental seguir a etapa 3 acima ([Proteção da Aplicação com WAF (Owasp Top Ten)](waf.md)), para garantir todas as funcionalidades apresentadas na introdução.

---------------------------------------------- 
## Implementação 
No vídeo abaixo é possível ver a implementação do projeto completo.  

<iframe width="630" height="450" src="https://www.youtube.com/embed/z0gkqTylu5k" title="Hospede seu Site com Segurança na AWS" frameborder="0" allow="accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture; web-share" allowfullscreen></iframe>
