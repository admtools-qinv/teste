# 🔥 Plano de Hardening de Firewall — Ubuntu 24.04 Azure VM

**Status: ⏳ PENDENTE APROVAÇÃO**  
**Data:** 2026-02-23  
**Autor:** Agente de Segurança (Grupo B)

---

## 📋 Situação Atual

| Item | Estado |
|------|--------|
| UFW | **Inativo** |
| iptables | Todas as policies em ACCEPT (sem proteção) |
| SSH (porta 22) | Único acesso primário |
| Gateway (18789) | ✅ Bind em 127.0.0.1 (seguro) |
| Portas 7070/9090 | ✅ Via SSH tunnel (não expostas em 0.0.0.0) |
| PasswordAuthentication | ✅ `no` (desabilitado via sshd_config.d/) |
| PermitRootLogin | ⚠️ Comentado (default: `prohibit-password`) |
| PubkeyAuthentication | ⚠️ Comentado (default: `yes`) |

---

## Etapa 1 — Ativar UFW com regras básicas

**⚠️ EXECUTAR NESTA ORDEM EXATA para não perder acesso SSH:**

```bash
# 1. Garantir que SSH será permitido ANTES de ativar o firewall
sudo ufw allow 22/tcp comment 'SSH'

# 2. Definir política padrão: bloquear tudo que entra
sudo ufw default deny incoming

# 3. Permitir tráfego de saída
sudo ufw default allow outgoing

# 4. Ativar o firewall (vai pedir confirmação)
sudo ufw enable

# 5. Verificar status
sudo ufw status verbose
```

> **IMPORTANTE:** O comando `ufw allow 22/tcp` deve ser executado **antes** de `ufw enable`. Caso contrário, você será desconectado imediatamente.

---

## Etapa 2 — Hardening SSH

### 2.1 Resultado da verificação atual:

- `PasswordAuthentication no` → ✅ Já configurado em `/etc/ssh/sshd_config.d/`
- `PermitRootLogin` → ⚠️ Comentado no config principal (usa default `prohibit-password`)
- `PubkeyAuthentication` → ⚠️ Comentado (usa default `yes`)

### 2.2 Recomendações:

```bash
# Criar arquivo de hardening dedicado
sudo tee /etc/ssh/sshd_config.d/99-hardening.conf << 'EOF'
PermitRootLogin no
PubkeyAuthentication yes
PasswordAuthentication no
MaxAuthTries 3
LoginGraceTime 20
X11Forwarding no
AllowAgentForwarding yes
AllowTcpForwarding yes
EOF

# Testar config antes de reiniciar
sudo sshd -t

# Se OK, reiniciar SSH
sudo systemctl restart sshd
```

> **Nota:** `AllowTcpForwarding yes` é necessário para manter os túneis SSH das portas 7070 e 9090.

### 2.3 Instalar fail2ban:

```bash
sudo apt update && sudo apt install -y fail2ban
sudo systemctl enable --now fail2ban

# Criar config local (não editar jail.conf diretamente)
sudo tee /etc/fail2ban/jail.local << 'EOF'
[sshd]
enabled = true
port = 22
maxretry = 5
bantime = 3600
findtime = 600
EOF

sudo systemctl restart fail2ban
```

---

## Etapa 3 — Verificar Azure NSG (Network Security Group)

**⚠️ AÇÃO MANUAL NECESSÁRIA no Portal Azure:**

1. Acesse **Portal Azure** → sua VM → **Networking** → **Network Security Group**
2. Verifique as regras de entrada (Inbound rules):
   - Deve existir regra permitindo **TCP 22** (SSH)
   - Idealmente, restringir o IP de origem ao seu IP fixo/range
   - Remover regras que permitam acesso amplo (ex: `0.0.0.0/0` em portas além de 22)
3. NSG é a **primeira camada** de firewall (antes de chegar na VM). UFW é a segunda.

---

## Etapa 4 — Procedimento de Rollback (se perder acesso)

### Opção A: Azure Serial Console
1. Portal Azure → VM → **Serial Console**
2. Logar com credenciais locais
3. Desabilitar UFW:
   ```bash
   sudo ufw disable
   ```

### Opção B: Azure Run Command
1. Portal Azure → VM → **Run Command**
2. Executar:
   ```bash
   ufw disable
   ```

### Opção C: Reset SSH Extension
1. Portal Azure → VM → **Extensions** → **Reset SSH**
2. Ou via CLI:
   ```bash
   az vm user reset-ssh --resource-group <RG> --name <VM>
   ```

### Prevenção:
- **Antes de ativar o UFW**, abra uma **segunda sessão SSH** e mantenha aberta
- Se a nova sessão não conectar após `ufw enable`, use a sessão existente para `sudo ufw disable`

---

## ✅ Checklist de Execução

- [ ] Abrir segunda sessão SSH como backup
- [ ] Executar Etapa 1 (UFW)
- [ ] Verificar que SSH ainda funciona na segunda sessão
- [ ] Executar Etapa 2 (SSH hardening)
- [ ] Verificar que SSH ainda funciona
- [ ] Instalar fail2ban (Etapa 2.3)
- [ ] Verificar Azure NSG (Etapa 3)
- [ ] Testar acesso SSH final

---

**⏳ ESTE PLANO AGUARDA APROVAÇÃO. Nenhuma alteração foi executada.**
