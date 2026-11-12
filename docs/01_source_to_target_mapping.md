### Products Data Validation Rules

| Column | Validation Rule | Reason |
|---|---|---|
| ProductID | Must not be NULL | Required product identifier |
| ProductID | Must be unique | Prevent duplicate products |
| ProductName | Must not be NULL | Required field in cleaned table |
| SupplierID | Non-NULL values must reference an existing supplier | Maintain referential integrity |
| CategoryID | Non-NULL values must reference an existing category | Maintain referential integrity |
| QuantityPerUnit | Correct identified double spaces | Standardize product descriptions |
| UnitPrice | Compatible with decimal(19,4) | Preserve numeric precision |
| Discontinued | Must not be NULL | Required product status |

### Handling Missing Values

- Staging allows NULL values in all Products columns.
- Cleaned.Products requires ProductID,
  ProductName and Discontinued.
- Optional NULL values are preserved.
- Invalid required values must be detected
  before loading the cleaned table.

### ETL Implementation

- Source-to-staging loading: SSIS Data Flow
- Staging-to-cleaned loading: T-SQL stored procedure
- Existing cleansing: REPLACE() for QuantityPerUnit
- Duplicate prevention: ProductID-based UPSERT
- Error handling: TRY/CATCH and transaction

### Products Data Quality Test Results

**Tested table:** NorthwindIntegration.cleaned.Products

**Total records:** 77

| Test | Result | Status |
|---|---|---|
| Missing ProductID | 0 | Passed |
| Missing ProductName | 0 | Passed |
| Missing Discontinued | 0 | Passed |
| Duplicate ProductID | 0 | Passed |
| Invalid SupplierID references | 0 | Passed |
| Invalid CategoryID references | 0 | Passed |
| QuantityPerUnit double spaces after cleaning | 0 | Passed |

### Transformation Evidence

**Identified issue:**

ProductID 36 contained a double-space pattern
in QuantityPerUnit.

Before: `24 - 250 g  jars`

After: `24 - 250 g jars`

**Transformation used:**

`REPLACE(s.QuantityPerUnit, '  ', ' ')`

**Implementation:**

SQL Server stored procedure:
`cleaned.usp_UpsertProducts`

**Validation:**

Compared staging and cleaned QuantityPerUnit
values and checked for remaining double spaces.

**Result:** Passed.

### Conclusion

The Products ETL successfully loaded 77 records
and passed the documented data quality checks.

The current cleaning rule addresses the identified
double-space pattern in QuantityPerUnit.
Additional data quality rules will be implemented
and tested separately in SSIS.


## 2. Other Table Mappings

All tables use the following ETL process:

Northwind Source → SSIS → Staging → Cleaned

| Source Table | Staging Table | Cleaned Table | Transformation |
|---|---|---|---|
| dbo.Shippers | staging.Shippers | cleaned.Shippers | Direct mapping |
| dbo.Categories | staging.Categories | cleaned.Categories | Direct mapping |
| dbo.Suppliers | staging.Suppliers | cleaned.Suppliers | Preserve valid optional NULLs |
| dbo.Customers | staging.Customers | cleaned.Customers | Correct identified double spaces in CompanyName and Address |
| dbo.Orders | staging.Orders | cleaned.Orders | Direct mapping; preserve valid NULLs |
| dbo.[Order Details] | staging.OrderDetails | cleaned.OrderDetails | Direct mapping; composite key: OrderID + ProductID |

### ETL Implementation

- Source-to-staging: SSIS Data Flow packages
- Staging-to-cleaned: SSIS packages and T-SQL UPSERT logic
- Data validation: Required fields, duplicates,
  foreign-key relationships and record counts
- Execution: Master SSIS Package
- Repeatability: Tested with unchanged source data

### Validation Summary

| Table | Cleaned Records |
|---|---:|
| Shippers | 3 |
| Categories | 8 |
| Suppliers | 29 |
| Products | 77 |
| Customers | 91 |
| Orders | 830 |
| OrderDetails | 2155 |
| Total | 3193 |
