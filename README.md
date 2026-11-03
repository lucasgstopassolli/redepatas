# 🐾 RedePatas

Aplicativo móvel comunitário desenvolvido em **Flutter (Material 3)** para registrar, organizar e acompanhar solicitações de apoio para animais em situação de rua que necessitam de **Água**, **Alimento**, **Abrigo** ou **Socorro/Cuidados** em **Rio do Sul (SC)** e região do **Alto Vale do Itajaí**.

* **Disciplina:** Desenvolvimento para Plataformas Móveis
* **Curso:** Sistemas de Informação (Projeto de Extensão — Desenvolvimento e Cidadania)
* **Equipe:** Ariel Jahn e Lucas Gabriel Stopassoli

---

## ✨ Funcionalidades Principais

1. **Boas-Vindas e Identificação Rápida (`WelcomeScreen`)**:
   - Acesso simplificado (Entrar, Criar Conta ou modo Visitante/Demonstração).
2. **Mural Comunitário (`HomeRequestsScreen` — Aba `Início`)**:
   - Busca textual por bairro, espécie ou necessidade.
   - Filtros rápidos por categoria (`Todos`, `💧 Água`, `🥣 Alimento`, `🏠 Abrigo`, `🚨 Urgentes`, `✓ Concluídos`) e filtro por município.
3. **Ciclo de Vida e Atendimento (`RequestDetailScreen`)**:
   - Status claros: **`Aberto`**, **`Em atendimento`** e **`Concluído`**.
   - Fluxo **"Quero Ajudar este Animal"** com registro do compromisso do voluntário e botão direto para contato via **WhatsApp**.
4. **Minhas Ações (`MyActionsScreen` — Aba `Pedidos`)**:
   - Sub-abas **Estou ajudando** e **Criados por mim**.
5. **Cadastro de Solicitação (`NewRequestScreen` — Aba `Novo`)**:
   - Múltiplas necessidades (`Água`, `Alimento`, `Abrigo`, `Socorro/Cuidados`) e Nível de Urgência (`Normal`, `Alta`, `Crítica`).
   - **Localização Inteligente**: Bairros oficiais de **Rio do Sul - SC** pré-configurados + integração com a **API oficial do IBGE** para todos os municípios de Santa Catarina.
   - Captura opcional de foto via Câmera ou Galeria (`image_picker`).
6. **Guia & Minha Área (`ProfileGuideScreen` — Aba `Minha área`)**:
   - Seletor persistente de Tema (`☀️ Claro`, `🌙 Escuro`, `📱 Sistema`) em paleta terrosa/terracota.
   - Guia Rápido de Abordagem Segura e Contatos Úteis (APAD Rio do Sul, Prefeitura/Bem-Estar Animal, Bombeiros 193, PM 190).

---

## 🚀 Como Executar

```bash
flutter pub get
flutter run
```
