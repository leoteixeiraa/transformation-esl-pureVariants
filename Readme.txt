Sobre este projeto
==================

Este projeto demonstra vários tipos de elementos de origem da transformação padrão em ação.
O código-fonte resultante pode ser compilado e a documentação gerada pode ser visualizada
em um visualizador HTML. Para mais informações sobre a transformação padrão, consulte o
“Guia do Usuário do pure::variants” na seção “Standard Transformation”.


Configuração inicial
====================

Abra a visão “Variant Project” e, pelo menu de contexto, abra as propriedades de “Config”.
Selecione o item “Configuration Space” e vá para a página “Input-Output”. Verifique os
caminhos exibidos e altere-os para valores válidos, se necessário.

Nenhuma configuração adicional é necessária.


O exemplo em detalhes
=====================

Este exemplo demonstra o uso de alguns tipos de elementos de origem em conjunto com a
transformação padrão.

O componente “Build” do modelo de família “System.ccfm” contém dois tipos de elementos de
origem: ps:makefile e ps:fragment. Para o primeiro, há um tutorial de como utilizá-lo;
consulte http://www.pure-systems.com para acessar os tutoriais. Para o segundo, há outro
exemplo chamado “Fragment Example”. No componente “Flags”, um arquivo de flags é gerado
usando ps:flagfile. Também há um tutorial para arquivos de flags. Para o tipo ps:condxml,
como no componente “Documentation”, consulte o exemplo “Conditional Documents”.


Resultados da transformação
===========================

O resultado da transformação será armazenado em <Project>/GenSystem/ (ou qualquer outro
caminho especificado nas propriedades do Configuration Space). Durante a transformação,
classes, um makefile e arquivos de documentação são gerados a partir dos arquivos de entrada.