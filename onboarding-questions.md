# Onboarding Questions — QInv

> Gerado em 15/04/2026 a partir de `experiments/onboarding_reference/flutter/lib/onboarding_reference/data/default_steps.dart`

---

## Fluxo Completo (11 etapas)

| # | ID | Tipo | Google Auth |
|---|-----|------|:-----------:|
| 1 | `welcome` | Intro | -- |
| 2 | `experience` | Single Choice | -- |
| 3 | `goal` | Single Choice | -- |
| 4 | `comfort` | Single Choice | -- |
| 5 | `fullName` | Text Input | -- |
| 6 | `email` | Text Input | Pula |
| 7 | `emailCode` | Verification Code | Pula |
| 8 | `phone` | Phone Input | -- |
| 9 | `pin` | PIN Input | Pula |
| 10 | `confirmPin` | PIN Input | Pula |
| 11 | `trial` | Completion | -- |

---

## 1. Welcome (`welcome`)

- **Título:** "Let's get you *started.*"
- **Subtítulo:** "Ready in just a few steps."
- **Narração:** "Hey! Welcome. Let's get you started!"
- **CTA:** "Get started"

---

## 2. Experiência em Investimentos (`experience`)

- **Título:** "How long have you *been investing?*"
- **Subtítulo:** "We'll tailor your experience."
- **Narração:** "How long have you been investing?"

| Valor | Texto |
|-------|-------|
| `beginner` | I'm just getting started |
| `intermediate` | A few years of experience |
| `advanced` | I know my way around |

---

## 3. Objetivo Financeiro (`goal`)

- **Título:** "What's your *financial goal?*"
- **Subtítulo:** "Pick what matters most to you."
- **Narração:** "What's your financial goal?"

| Valor | Texto |
|-------|-------|
| `grow` | Grow my wealth over time |
| `passive` | Generate passive income |
| `preserve` | Protect what I already have |

---

## 4. Conforto com Risco (`comfort`)

- **Título:** "How do you handle *market swings?*"
- **Subtítulo:** "No wrong answers here."
- **Narração:** "How do you handle market swings?"

| Valor | Texto |
|-------|-------|
| `conservative` | I prefer stability above all |
| `moderate` | A balanced approach works for me |
| `aggressive` | I can handle the ups and downs |

---

## 5. Nome Completo (`fullName`)

- **Título:** "What's your *full name?*"
- **Subtítulo:** "As it appears on your official ID."
- **Narração:** "What's your full name? Nice to meet you, by the way."
- **Placeholder:** "John Doe"
- **Label de revisão:** "Full name"

---

## 6. Email (`email`) — *pulado no Google Auth*

- **Título:** "What's your *email address?*"
- **Subtítulo:** "We'll send a verification code."
- **Narração:** "What's your email address?"
- **Placeholder:** "you@example.com"
- **Label de revisão:** "Email"

---

## 7. Código de Verificação (`emailCode`) — *pulado no Google Auth*

- **Título:** "Check your *email.*"
- **Subtítulo:** "Enter the 6-digit code we sent you."
- **Narração:** "Check your email. We've sent you a code."
- **Placeholder:** "000000"
- **Formato:** 6 dígitos numéricos
- **Label de revisão:** "Email verified"

---

## 8. Telefone (`phone`)

- **Título:** "Add your *phone number.*"
- **Subtítulo:** "Used for two-factor authentication only."
- **Narração:** "Enter your phone number with country and area code."
- **Placeholder:** "+1 555 000 0000"
- **Label de revisão:** "Phone"

---

## 9. Criar PIN (`pin`) — *pulado no Google Auth*

- **Título:** "Create your *6-digit PIN.*"
- **Subtítulo:** "Used to authorize transactions."
- **Narração:** "We are almost there. Let's create your password!"
- **Formato:** 6 dígitos
- **Label de revisão:** "PIN"

---

## 10. Confirmar PIN (`confirmPin`) — *pulado no Google Auth*

- **Título:** "Confirm your *PIN.*"
- **Subtítulo:** "Enter the same PIN again."
- **Narração:** "Okay! Let's confirm your password."
- **Formato:** 6 dígitos (deve coincidir com `pin`)
- **Label de revisão:** "PIN confirmed"

---

## 11. Conclusão (`trial`)

- **Título:** "You're all set. *Let's get started.*"
- **Subtítulo:** "Your account is ready. Time to invest."
- **Narração:** "You're all set. Let's get started!"
- **CTA:** "Start investing"

---

## Mensagens de Validação

| Contexto | Mensagem |
|----------|----------|
| Nenhuma opção selecionada | "Please select one option." |
| Campo obrigatório vazio | "This field is required." |
| Email inválido | "Enter a valid email address." |
| Telefone inválido | "Enter a valid phone number." |
| Código de verificação inválido | "Enter the 6-digit code." |
| PIN vazio | "Please enter your PIN." |
| PIN != 6 dígitos | "PIN must be exactly 6 digits." |
| PINs não coincidem | "PINs don't match. Please try again." |
