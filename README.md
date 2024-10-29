# App de Controle de Acesso com Autenticação por Impressão Digital

## Descrição do Projeto
Este aplicativo oferece um controle de acesso seguro para áreas restritas utilizando autenticação biométrica por impressão digital, com validação em uma localização específica para maior segurança. Após a autenticação, os usuários podem visualizar o calendário menstrual, registrar dados do ciclo, ou acessar anotações pessoais. O banco de dados armazena registros de acessos com data, hora e localização, além de informações do ciclo menstrual e anotações.

---

## Objetivos SMART
1. **Específico:** Criar um app com controle de acesso por impressão digital, ferramenta de gestão do ciclo menstrual e anotações pessoais.
2. **Mensurável:** Alcançar 90% de precisão na autenticação e 80% de sucesso nos registros de ciclo e anotações.
3. **Atingível:** Implementar funcionalidades principais com a equipe atual e realizar testes com usuários.
4. **Relevante:** Proteger áreas corporativas e fornecer uma ferramenta útil para gestão de saúde e anotações.
5. **Temporal:** Concluir o desenvolvimento em 4 meses, com uma fase de testes beta de 2 semanas.

---

## Funcionalidades Implementadas e Decisões de Design

### 1. Autenticação Biométrica e Validação Geográfica
- **Descrição:** A autenticação biométrica é validada apenas em localizações específicas, limitando o acesso a áreas restritas. 
- **Decisões de Design:** Tela de autenticação minimalista, com destaque nos botões de "Cadastro" e "Login" e validação da localização no momento do login.

### 2. Gestão do Ciclo Menstrual e Calendário
- **Descrição:** Ferramenta de calendário para registro do ciclo menstrual, com opção de registrar a duração e dias específicos.
- **Decisões de Design:** Interface interativa com ícones representativos para facilitar a navegação e visualização dos registros.

### 3. Lista de Tarefas e Anotações
- **Descrição:** Página dedicada à gestão de tarefas e anotações pessoais. Opções para editar, excluir e marcar como concluídas.
- **Decisões de Design:** Interface intuitiva com campos para adicionar tarefas e ícones para edição e exclusão, facilitando o uso.

---

## Uso de APIs Externas e Integração com Firebase

### Firebase
- **Autenticação:** Gerencia cadastro e login dos usuários com autenticação segura.
- **Banco de Dados:** Firebase Firestore armazena registros de acessos, ciclo menstrual e tarefas/anotações.

### APIs de Geolocalização
- **Uso:** Valida a localização do usuário no momento do login, garantindo o acesso somente em áreas específicas.
- **Decisões de Design:** Realiza a validação em tempo real para reforçar a segurança do acesso.

---

## Desafios e Soluções

### 1. Precisão da Validação Biométrica
- **Desafio:** A precisão variava em diferentes dispositivos.
- **Solução:** Sessão de treinamento para o usuário e integração de uma biblioteca de autenticação biométrica compatível com uma ampla gama de dispositivos Android e iOS.

### 2. Segurança dos Dados no Firebase
- **Desafio:** Proteção dos dados sensíveis armazenados.
- **Solução:** Regras de segurança do Firebase para restrição de acesso, criptografia de dados em trânsito e auditorias semanais para monitorar atividades.

### 3. Sincronização da Localização para Acesso Controlado
- **Desafio:** Geolocalização imprecisa em áreas com sinal fraco.
- **Solução:** Verificações periódicas de localização para melhorar a precisão e a opção de redefinir a localização preferida.

---

## Passo a Passo para Rodar o Aplicativo Localmente

1. Instale o VSCode, Flutter e faça as configurações necessárias.
2. Conecte seu dispositivo móvel ao computador via cabo USB.
3. No VSCode, selecione o dispositivo conectado.
4. No terminal, execute `flutter run` para iniciar o aplicativo.

---

## Tutorial de Uso

### Página Inicial - Controle de Acesso
- **Cadastro:** Crie uma nova conta.
- **Login:** Acesse o sistema com uma conta existente.

### Navbar
- **Menu de Navegação:** Permite a navegação entre as funcionalidades do app.

### Lista de Tarefas
- **Adicionar, Editar e Excluir Tarefas:** Gerencie suas atividades diárias.
  
### Calendário do Ciclo Menstrual
- **Registro de Ciclo:** Registre a duração e o início do ciclo.

---

Este guia fornece uma visão geral do app e suas funcionalidades para garantir uma experiência de uso otimizada. Com ele, os usuários têm controle sobre suas atividades e registros de forma segura e intuitiva.

### Diagrama de Classe
<img width="668" alt="Diagrama de Classe" src="https://github.com/user-attachments/assets/2d59df9a-cc52-486d-9db0-766743078cc9">

### Diagrama de Fluxo
<img width="363" alt="Diagrama de Fluxokk" src="https://github.com/user-attachments/assets/697c0bfa-de7c-4148-9859-3301a80a8d40">

