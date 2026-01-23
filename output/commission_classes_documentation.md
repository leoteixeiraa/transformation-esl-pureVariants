# Classes Relacionadas à Feature Commissioning

## Resumo Executivo
A feature **Commissioning** (Comissionamento) é responsável por associar uma etiqueta eletrônica (ESL) a um produto específico através do MAC da etiqueta e do EAN/GTIN do produto.

---

## 1. Views/Widgets (Camada de Apresentação)

### 1.1 Views Principais

#### `CommissioningView` 
**Arquivo:** `lib/views/Commissioning/commissioning_view.dart`
- **Tipo:** `StatefulWidget` com `_CommissioningViewState`
- **Propósito:** Tela principal de comissionamento (versão legada/alternativa)
- **Responsabilidades:**
  - Formulário com campos para MAC e EAN
  - Scanner de código de barras (MAC e EAN)
  - Validação de dados
  - Chamada ao `CommissioningProcessManager` para executar comissionamento
  - Tratamento de timeouts e respostas de erro

#### `CommissioningOptionsView`
**Arquivo:** `lib/views/Commissioning/commissioning_options_view.dart`
- **Tipo:** `StatefulWidget` com `_CommissioningOptionsViewState`
- **Propósito:** Menu de opções para operações de comissionamento
- **Responsabilidades:**
  - Navegação para telas de comissionamento
  - Navegação para logs de comissionamento
  - Menu com opções disponíveis ao usuário

#### `CommissioningLogsView`
**Arquivo:** `lib/views/Commissioning/commissioning_logs_view.dart`
- **Tipo:** `StatefulWidget` com `_CommissioningLogsViewState`
- **Propósito:** Visualização do histórico de comissionamentos
- **Responsabilidades:**
  - Exibir lista de comissionamentos realizados pelo funcionário
  - Usa `FutureBuilder` para carregar dados via `CommissioningDao`
  - Renderiza itens usando `LmCommissioningLogItem`

### 1.2 Views do Fluxo de Comissionamento (Wizard)

#### `Step1CommissionMacReader`
**Arquivo:** `lib/views/Commissioning/step1_commission_macReader.dart`
- **Tipo:** `StatefulWidget` com `_Step1CommissionMacReaderState`
- **Propósito:** Passo 1 - Captura do MAC via scanner de câmera
- **Responsabilidades:**
  - Integração com câmera do dispositivo
  - Processamento de imagens via `BarcodeScanner` (MLKit)
  - Validação do MAC usando `MacValidationService`
  - Navegação para próximo passo com `CommissioningArguments`
  - Permite alternar para input manual (`Step1CommissionMacInput`)

#### `Step1CommissionMacInput`
**Arquivo:** `lib/views/Commissioning/step1_commission_macInput.dart`
- **Tipo:** `StatefulWidget` com `_Step1CommissionMacInputState`
- **Propósito:** Passo 1 - Input manual do MAC da etiqueta
- **Responsabilidades:**
  - Formulário para digitação manual do MAC
  - Validação de formato MAC via `MyTextField` (shouldValidateInputAsMac)
  - Armazenamento em `CommissioningArguments`
  - Navegação para `/commissioning/commission/eanReader`

#### `Step2CommissionEanReader`
**Arquivo:** `lib/views/Commissioning/step2_commission_eanReader.dart`
- **Tipo:** `StatefulWidget` com `_Step2CommissionEanReaderState`
- **Propósito:** Passo 2 - Captura do EAN/GTIN do produto via scanner
- **Responsabilidades:**
  - Scanner de código de barras do produto
  - Suporta múltiplos formatos de barcode
  - Recebe `CommissioningArguments` do step anterior
  - Permite alternar para input manual (`Step2CommissionEanInput`)

#### `Step2CommissionEanInput`
**Arquivo:** `lib/views/Commissioning/step2_commission_eanInput.dart`
- **Tipo:** `StatefulWidget` com `_Step2CommissionEanInputState`
- **Propósito:** Passo 2 - Input manual do EAN/GTIN do produto
- **Responsabilidades:**
  - Formulário para digitação manual do código do produto
  - Atualiza `CommissioningArguments` com EAN
  - Navegação para `/commissioning/commission/checkout`

#### `Step3CommissionCheckout`
**Arquivo:** `lib/views/Commissioning/step3_commission_checkout.dart`
- **Tipo:** `StatelessWidget`
- **Propósito:** Passo 3 - Revisão e confirmação do comissionamento
- **Responsabilidades:**
  - Exibir dados coletados (MAC e EAN) para revisão
  - Usa `TagInfoCheckoutCard` para exibir MAC
  - Usa `ProductInfoCheckoutCard` para exibir EAN
  - Botão para executar comissionamento via `CommissioningProcessManager`
  - Tratamento de timeout e erros
  - Exibição de dialogs de sucesso/erro via `MyActionsAlertDialog` e `MyAlertDialog`

#### `Step0CommissioningActions`
**Arquivo:** `lib/views/actions/step0_commissioning_actions.dart`
- **Tipo:** `StatefulWidget` com `_Step0CommissioningActionsState`
- **Propósito:** Menu de ações de comissionamento/descomissionamento
- **Responsabilidades:**
  - Botão para iniciar comissionamento
  - Botão para iniciar descomissionamento
  - Navegação para as respectivas telas

---

## 2. DTOs (Data Transfer Objects)

### `CommissioningDto`
**Arquivo:** `lib/dto/commissioning_dto.dart`
- **Tipo:** Classe que estende `Dto`
- **Propósito:** Transferência de dados de comissionamento entre camadas
- **Atributos principais:**
  - `action`: String = 'commission'
  - `mac`: MAC (objeto)
  - `product`: Product (objeto)
  - `clientId`: int
  - `timestamp`: String (herdado)
  - `employeeLeroyCode`: String (herdado)
  - `authToken`: String (herdado)
  - `mongoUsrActionsObjectId`: String? (herdado)
  - `statusDecription`: String? (herdado)
- **Métodos:**
  - `factory CommissioningDto.fromJson()`: Cria DTO a partir de JSON
  - `toJson()`: Serializa para JSON
  - `dataToJson()`: Dados para payload de requisição
  - `mappingConnectorBodyRequest()`: Monta body para requisição ao Connector
  - `mappingMongoBodyRequest()`: Monta body para requisição ao MongoDB

---

## 3. DAOs (Data Access Objects)

### `CommissioningDao`
**Arquivo:** `lib/dao/commissioning_dao.dart`
- **Tipo:** Classe que estende `Dao`
- **Propósito:** Acesso a dados de comissionamento via API
- **Métodos:**
  - `Future<List<CommissioningDto>> getAllByEmployeeCode()`: 
    - Busca todos os comissionamentos do funcionário logado
    - Faz requisição GET para `/actions/commissions/{employeeCode}`
    - Converte resposta JSON em lista de `CommissioningDto`
    - Ordena por timestamp

---

## 4. Services (Camada de Lógica de Negócio)

### `CommissioningProcessManager`
**Arquivo:** `lib/services/commissioning_process_manager.dart`
- **Tipo:** Classe que estende `ProcessManager`
- **Propósito:** Gerenciar o processo de comissionamento
- **Métodos:**
  - `Future<http.Response> commission({required String sgtinParameter, required String macParameter})`:
    - Obtém dados do usuário via `CacheManagement`
    - Cria `CommissioningDto` com os parâmetros fornecidos
    - Envia dados para MongoDB primeiro (para auditoria)
    - Envia requisição para o Connector (sistema backend)
    - Retorna `Future<http.Response>` com resultado da operação
  - `Future<http.Response> decommission({required String macParameter})`:
    - Processo similar, mas para descomissionamento

---

## 5. Models (Modelos de Dados)

### `CommissioningArguments`
**Arquivo:** `lib/models/actionArguments/commission_arguments.dart`
- **Tipo:** Classe simples de argumentos
- **Propósito:** Passar dados entre telas do wizard de comissionamento
- **Atributos:**
  - `String? macAddress`: Endereço MAC da etiqueta
  - `String? ean`: Código EAN/GTIN do produto

### Modelos Utilizados (não exclusivos, mas relacionados):
- **`MAC`** (`lib/models/mac.dart`): Representa endereço MAC de uma etiqueta
- **`Product`** (`lib/models/Product.dart`): Representa um produto com SGTIN

---

## 6. Components (Componentes Reutilizáveis)

### `LmCommissioningLogItem`
**Arquivo:** `lib/components/lm_commissioning_log_item.dart`
- **Tipo:** `StatelessWidget` com subcomponente `_CommissioningDescription`
- **Propósito:** Widget customizado para exibir um item de log de comissionamento
- **Responsabilidades:**
  - Renderizar card com informações do `CommissioningDto`
  - Exibir: timestamp formatado, MAC, EAN, status, código do funcionário
  - Decodificar mensagens de status via `decodeNotificationMessage()`
  - Ícone de sucesso/falha

---

## 7. Rotas (Configuração em `lib/main.dart`)

```dart
'/commissioning': (context) => const Step0CommissioningActions(),
'/commissioning/commission/macReader': (context) => Step1CommissionMacReader(allowedBarcodeFormats: const [BarcodeFormat.code128]),
'/commissioning/commission/macInput': (context) => const Step1CommissionMacInput(),
'/commissioning/commission/eanReader': (context) => Step2CommissionEanReader(allowedBarcodeFormats: const [BarcodeFormat.all]),
'/commissioning/commission/eanInput': (context) => Step2CommissionEanInput(),
'/commissioning/commission/checkout': (context) => Step3CommissionCheckout(),
```

---

## 8. Testes

Segundo o mapeamento de features, os seguintes arquivos de teste estão relacionados:

- `test/connector_commissioning_test.dart`
- `test/connector_install_commission_test.dart`
- `test/api_commissioning_test.dart`
- `test/services/mac_validation_service_test.dart`
- `test/services/ignore_diacritics_service_test.dart`
- `test/physical_location_test.dart`

---

## 9. Assets

- `assets/esl/esl_ean_scan_indicator.png`: Indicador visual para scanner de EAN
- `assets/esl/esl_mac_scan_indicator.png`: Indicador visual para scanner de MAC

---

## 10. Dependências/Integrações

### Services Compartilhados:
- **`CacheManagement`**: Gerenciamento de cache e sessão do usuário
- **`MacValidationService`**: Validação de formato de endereço MAC
- **`Scanner`**: Wrapper para leitura de códigos de barras
- **`ProcessManager`**: Classe base para gerenciadores de processo

### Componentes Compartilhados:
- **`MyAlertDialog`**: Diálogo de alerta customizado
- **`MyActionsAlertDialog`**: Diálogo com ações pós-operação
- **`MySolidButton`**: Botão customizado sólido
- **`MyTextField`**: Campo de texto customizado com validações
- **`TagInfoCheckoutCard`**: Card de informações da etiqueta
- **`ProductInfoCheckoutCard`**: Card de informações do produto

### Bibliotecas Externas:
- **`google_mlkit_barcode_scanning`**: Scanning de códigos de barras via ML Kit
- **`camera`**: Acesso à câmera do dispositivo
- **`http`**: Requisições HTTP
- **`flutter_session_manager`**: Gerenciamento de sessão

---

## 11. Fluxo de Dados

```
???????????????????????????????????????????????????????????????
?                    Fluxo de Comissionamento                  ?
???????????????????????????????????????????????????????????????

1. Usuário ? CommissioningOptionsView
              ?
2. Seleciona "Comissionar" ? Step0CommissioningActions
              ?
3. Step1CommissionMacReader ou Step1CommissionMacInput
   - Captura/digita MAC
   - Cria CommissioningArguments(macAddress)
              ?
4. Step2CommissionEanReader ou Step2CommissionEanInput
   - Captura/digita EAN
   - Atualiza CommissioningArguments(macAddress, ean)
              ?
5. Step3CommissionCheckout
   - Exibe revisão (TagInfoCheckoutCard + ProductInfoCheckoutCard)
   - Confirma operação
              ?
6. CommissioningProcessManager.commission()
   - Obtém UserDto via CacheManagement
   - Cria CommissioningDto
   - sendToMongo() ? registra auditoria
   - sendToConnector() ? executa ação no sistema
              ?
7. Resposta do Connector
   - Sucesso: MyActionsAlertDialog (permite nova ação)
   - Falha: MyAlertDialog (exibe erro)
              ?
8. CommissioningLogsView
   - CommissioningDao.getAllByEmployeeCode()
   - Renderiza histórico com LmCommissioningLogItem
```

---

## 12. Variabilidade (PVSCL)

A feature Commissioning possui pontos de variabilidade controlados por diretivas `PVSCL:IFCOND(Commission)`:

### Arquivos Exclusivos:
Todos os arquivos em `lib/views/Commissioning/` (exceto decommissioning), `lib/dto/commissioning_dto.dart`, `lib/dao/commissioning_dao.dart`, e `lib/services/commissioning_process_manager.dart` são exclusivos da feature.

### Snippets Condicionais:
- Rotas em `lib/main.dart` (envolvidas em `/* PVSCL:IFCOND(Commission) */`)
- Imports e botões em `lib/views/operations_view.dart`
- Imports e navegação em `lib/views/actions/step0_commissioning_actions.dart`
- Integração em `lib/views/installationAndCommissioning/` (combina installation + commission)

---

## 13. Diagrama de Classes (Resumido)

```
????????????????????????
? CommissioningView    ? (Legado)
? (StatefulWidget)     ?
????????????????????????

????????????????????????
? CommissioningOptions ?
?      View            ?
????????????????????????
          ?
          ??? Step1CommissionMacReader
          ?   Step1CommissionMacInput
          ?        ?
          ?        ?
          ??? Step2CommissionEanReader
          ?   Step2CommissionEanInput
          ?        ?
          ?        ?
          ??? Step3CommissionCheckout
                   ?
                   ??? CommissioningProcessManager
                   ?         ?
                   ?         ??? CommissioningDto
                   ?         ?         ?
                   ?         ?         ??? MAC, Product
                   ?         ?
                   ?         ??? ProcessManager
                   ?                  (sendToMongo, sendToConnector)
                   ?
                   ??? CommissioningLogsView
                             ?
                             ??? CommissioningDao
                                      ?
                                      ??? List<CommissioningDto>
                                            ?
                                            ??? LmCommissioningLogItem
```

---

## 14. Lista Completa de Classes

### Views/Widgets (11 classes):
1. `CommissioningView` + `_CommissioningViewState`
2. `CommissioningOptionsView` + `_CommissioningOptionsViewState`
3. `CommissioningLogsView` + `_CommissioningLogsViewState`
4. `Step1CommissionMacReader` + `_Step1CommissionMacReaderState`
5. `Step1CommissionMacInput` + `_Step1CommissionMacInputState`
6. `Step2CommissionEanReader` + `_Step2CommissionEanReaderState`
7. `Step2CommissionEanInput` + `_Step2CommissionEanInputState`
8. `Step3CommissionCheckout`
9. `Step0CommissioningActions` + `_Step0CommissioningActionsState`
10. `LmCommissioningLogItem`
11. `_CommissioningDescription` (subcomponente)

### DTOs (1 classe):
12. `CommissioningDto`

### DAOs (1 classe):
13. `CommissioningDao`

### Services (1 classe):
14. `CommissioningProcessManager`

### Models (1 classe):
15. `CommissioningArguments`

### Total: 15 classes principais + estados associados

---

## 15. Observações Importantes

1. **Arquitetura em Camadas**: O código segue uma separação clara entre View ? Service ? DAO ? DTO
2. **Wizard Pattern**: O fluxo de comissionamento usa um padrão de wizard em 3 passos
3. **Dual Input**: Cada passo permite tanto scanner quanto input manual
4. **Timeout Handling**: Todas as operações de rede têm timeout configurado (ZEROMQ_TIMEOUT_VALUE)
5. **Auditoria**: Registra no MongoDB antes de enviar ao Connector
6. **Notificações**: Sistema integrado com Firebase para notificações de falha
7. **Validação**: MAC é validado com `MacValidationService`
8. **Shared State**: Usa `CommissioningArguments` para passar dados entre steps

---

**Documento gerado automaticamente a partir do código-fonte em:**  
`c:\purevariants_repo\Transformation ESL\System\src\esl_mobile_app\`

**Data:** 2025-12-05
