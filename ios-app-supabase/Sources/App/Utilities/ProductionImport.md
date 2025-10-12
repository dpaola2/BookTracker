# Importing Production Books

Use this guide to import books from the existing production application into Supabase.

1. Export the production books as JSON (matching the attributes `title`, `author`, `isbn`, `notes`, and `shelf_name`).
2. Create corresponding shelves in Supabase if they do not already exist.
3. Use the SQL snippet below in the Supabase SQL editor to insert the records. Replace `:user_id` with the authenticated user ID that should own the data.

```sql
insert into shelves (id, name, description, user_id)
select distinct gen_random_uuid(), shelf_name, null, ':user_id'
from jsonb_populate_recordset(null::record, :json_data) as (shelf_name text);

insert into books (id, title, author, isbn, notes, shelf_id, user_id)
select
  gen_random_uuid(),
  book->>'title',
  book->>'author',
  book->>'isbn',
  coalesce(book->>'notes', ''),
  (select id from shelves where name = book->>'shelf_name' limit 1),
  ':user_id'
from jsonb_array_elements(:json_data) as book;
```

Alternatively, create a small script that leverages the Supabase REST API. The `SupabaseImportService` demonstrates how to batch insert records programmatically if you prefer to run the migration from inside the app.
