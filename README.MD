# 🔁 Idempotent Lakehouse Ingestion Pipeline in Microsoft Fabric

This project demonstrates a **production-grade, file-based ingestion pipeline** built entirely within Microsoft Fabric. It handles evolving JSON schemas, late-arriving data, file-level checkpointing, and deduplication—designed to reflect the architecture and rigor of real-world enterprise pipelines.

---

## 🚀 Features

- **Lakehouse architecture**: Bronze → Silver layering using Delta tables
- **Idempotent ingestion**: Re-processing safe through checkpoint tracking
- **Content-based deduplication**: Prevents duplicated records across reruns
- **Schema evolution**: Automatically absorbs new fields (e.g. `device_type`)
- **Notebook-driven orchestration**: With pipeline support and scheduling
- **Attribution modeling (bonus)**: Includes a SQL-based linear attribution example for marketing analytics

---

## 🏗️ Tech Stack

- **Microsoft Fabric**: Lakehouse, Notebooks, Pipelines
- **Delta Lake**: For schema enforcement and ACID guarantees
- **PySpark (Spark Notebooks)**: For transformation and deduplication logic
- **T-SQL**: For Silver → Warehouse logic and attribution analysis



## 🧠 Key Learnings & Gotchas

These are the real takeaways that surfaced while building and debugging the project:

1. **🚫 No Trigger Scheduling on Free Fabric Capacity**  
   Tried to set up daily triggers—got a monitor-related error. Realized **triggers and alerts require a paid Fabric capacity**.

2. **📛 Case Sensitivity in Lakehouse Paths**  
   Spark paths like `Files/bronze/` are **case-sensitive**. Accidentally used `Files/Bronze/` and ran into a confusing `PATH_NOT_FOUND` error.

3. **🔍 `input_file_name()` + Dirty Data Can Break Reads**  
   When reading corrupted JSONs with `input_file_name()`, Spark either fails or returns nulls. Learned to apply schema checks *before* tagging source file metadata.

4. **🧬 MergeSchema Helps—But Needs Flat Structure**  
   `mergeSchema=true` enables schema evolution, but struggles with nested fields. **Flattening early** avoids hard-to-detect type mismatch issues.

5. **🔑 Content-Based Deduplication Wins**  
   Primary keys weren’t always reliable due to nulls. Used **SHA2 hashes over all relevant columns** to generate a stable `dedup_key`.

6. **🎭 Observability Gap in Pipelines**  
   Fabric pipelines (as of this build) **don’t expose detailed logs or alerts** for free-tier users. Used `print()` inside notebooks and notebook chaining as workarounds.

7. **⚖️ Realization: Value Isn’t in a Gold Layer—It’s in the Hygiene**  
   Just Bronze → Silver with idempotent deduping and schema drift handling is already an impactful, production-ready pattern.

---

## 📈 Bonus: Attribution Model for Analytics

Check out `sql/attribution_linear_model.sql` for a **multi-touch linear attribution model**, assigning fractional conversion credit to each marketing channel leading up to a purchase event.

---

## 🛠️ How to Reproduce

1. Upload the JSON files to your Fabric Lakehouse at: `Files/Bronze/`
2. Run `bronze_to_silver_notebook.ipynb` to clean and stage into `silver_user_events`
3. Create checkpoint table:  
   ```sql
   CREATE TABLE bronze_file_checkpoints (source_file STRING, load_time TIMESTAMP)
   USING DELTA;
4. Run silver_pipeline_etl_with_checkpoint.ipynb to:
- Filter unprocessed files
- Deduplicate records
- Append to Silver Delta table and update checkpoints
5. Optional: Create a pipeline to automate and schedule the notebook (requires paid capacity)


