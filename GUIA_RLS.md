# Guia para Aplicar Políticas RLS no Supabase

## Problema Identificado
O erro `"new row violates row-level security policy for table \"user_quizzes\""` indica que as políticas RLS (Row Level Security) não estão configuradas corretamente na tabela `user_quizzes`.

## Solução

### 1. Acesse o Painel do Supabase
1. Vá para [supabase.com](https://supabase.com)
2. Faça login na sua conta
3. Selecione o projeto `intellimenv1`

### 2. Navegue para Authentication > Policies
1. No menu lateral, clique em **Authentication**
2. Clique em **Policies**

### 3. Selecione a Tabela user_quizzes
1. Na lista de tabelas, encontre `user_quizzes`
2. Clique na tabela para ver as políticas existentes

### 4. Adicione as Políticas Necessárias

#### Política 1: Inserção de Registros Próprios
```sql
CREATE POLICY "Users can insert their own quiz records" 
ON "public"."user_quizzes"
FOR INSERT WITH CHECK (auth.uid() = user_id);
```

#### Política 2: Atualização de Registros Próprios
```sql
CREATE POLICY "Users can update their own quiz records" 
ON "public"."user_quizzes"
FOR UPDATE USING (auth.uid() = user_id);
```

#### Política 3: Visualização de Registros Próprios
```sql
CREATE POLICY "Users can view their own quiz records" 
ON "public"."user_quizzes"
FOR SELECT USING (auth.uid() = user_id);
```

#### Política 4: Visualização de Registros onde o Usuário é Parceiro
```sql
CREATE POLICY "Users can view records where they are partner" 
ON "public"."user_quizzes"
FOR SELECT USING (auth.uid() = partner_id);
```

### 5. Como Aplicar as Políticas

#### Opção A: Via Interface Web
1. Clique em **"New Policy"** na tabela `user_quizzes`
2. Para cada política:
   - **Name**: Nome da política (ex: "Users can insert their own quiz records")
   - **Operation**: Selecione INSERT, UPDATE ou SELECT
   - **Target roles**: Deixe vazio (para todos os usuários autenticados)
   - **Using expression**: Para SELECT/UPDATE, use `auth.uid() = user_id`
   - **With check expression**: Para INSERT, use `auth.uid() = user_id`
   - Para a política de parceiro, use `auth.uid() = partner_id`

#### Opção B: Via SQL Editor
1. Vá para **SQL Editor** no menu lateral
2. Cole e execute cada comando SQL acima
3. Execute um comando por vez

### 6. Verificar se as Políticas Foram Aplicadas

Execute este comando no SQL Editor para verificar:

```sql
SELECT 
    schemaname,
    tablename,
    policyname,
    permissive,
    roles,
    cmd,
    qual,
    with_check
FROM pg_policies 
WHERE tablename = 'user_quizzes';
```

### 7. Testar as Políticas

Após aplicar as políticas, execute o script de teste:

```bash
dart run test_rls_simple.dart
```

Se tudo estiver correto, você deve ver:
```
✅ Inserção bem-sucedida! As políticas RLS estão funcionando.
```

## Explicação das Políticas

- **INSERT**: Permite que usuários autenticados insiram registros onde `user_id` é igual ao seu ID
- **UPDATE**: Permite que usuários autenticados atualizem seus próprios registros
- **SELECT**: Permite que usuários vejam seus próprios registros E registros onde são parceiros
- **auth.uid()**: Função do Supabase que retorna o ID do usuário autenticado

## Importante

- As políticas só funcionam quando o usuário está autenticado
- O app Flutter deve estar usando o cliente Supabase autenticado
- Se ainda houver problemas, verifique se RLS está ativo na tabela

## Comandos SQL Completos

Se preferir aplicar tudo de uma vez, use este SQL:

```sql
-- Política 1: Inserção
CREATE POLICY "Users can insert their own quiz records" 
ON "public"."user_quizzes"
FOR INSERT WITH CHECK (auth.uid() = user_id);

-- Política 2: Atualização
CREATE POLICY "Users can update their own quiz records" 
ON "public"."user_quizzes"
FOR UPDATE USING (auth.uid() = user_id);

-- Política 3: Visualização própria
CREATE POLICY "Users can view their own quiz records" 
ON "public"."user_quizzes"
FOR SELECT USING (auth.uid() = user_id);

-- Política 4: Visualização como parceiro
CREATE POLICY "Users can view records where they are partner" 
ON "public"."user_quizzes"
FOR SELECT USING (auth.uid() = partner_id);
```

Após aplicar essas políticas, o app deve conseguir inserir e atualizar registros na tabela `user_quizzes` corretamente. 