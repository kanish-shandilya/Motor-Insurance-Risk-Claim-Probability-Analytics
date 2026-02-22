-- ============================================================
-- Project: Motor Insurance Risk & Claim Probability Analytics
-- Author: Kanish Shandilya
-- Database: insurance_risk_db
-- Table: insurance_claims
--
-- Objective:
-- Perform business-level risk analytics using SQL.
-- Evaluate claim rates, segment risk, demographic risk,
-- safety feature impact, and validate engineered risk tiers.
-- ============================================================



-- ============================================================
-- SECTION 1: CORE PORTFOLIO KPIs
-- ============================================================

-- 1. Total Policies in Portfolio
SELECT COUNT(*) AS total_policies
FROM insurance_claims;



-- 2. Total Claims
-- claim_status is stored as TEXT (0/1), so we cast to INT
SELECT SUM(claim_status::INT) AS total_claims
FROM insurance_claims;



-- 3. Overall Claim Rate (Primary Risk KPI)
-- Claim Rate = Total Claims / Total Policies
SELECT 
    SUM(claim_status::INT)::FLOAT / COUNT(*) AS overall_claim_rate
FROM insurance_claims;



-- ============================================================
-- SECTION 2: SEGMENT RISK ANALYSIS
-- ============================================================

-- 4. Claim Rate by Vehicle Segment
-- Business Question:
-- Which vehicle segments are highest risk?

SELECT 
    segment,
    COUNT(*) AS total_policies,
    SUM(claim_status::INT) AS total_claims,
    SUM(claim_status::INT)::FLOAT / COUNT(*) AS claim_rate
FROM insurance_claims
GROUP BY segment
ORDER BY claim_rate DESC;



-- ============================================================
-- SECTION 3: DEMOGRAPHIC RISK ANALYSIS
-- ============================================================

-- 5. Claim Rate by Customer Age Band
SELECT 
    customer_age_band,
    COUNT(*) AS total_policies,
    SUM(claim_status::INT) AS total_claims,
    SUM(claim_status::INT)::FLOAT / COUNT(*) AS claim_rate
FROM insurance_claims
GROUP BY customer_age_band
ORDER BY claim_rate DESC;



-- 6. Claim Rate by Vehicle Age Band
SELECT 
    vehicle_age_band,
    COUNT(*) AS total_policies,
    SUM(claim_status::INT) AS total_claims,
    SUM(claim_status::INT)::FLOAT / COUNT(*) AS claim_rate
FROM insurance_claims
GROUP BY vehicle_age_band
ORDER BY claim_rate DESC;



-- ============================================================
-- SECTION 4: REGION RISK INDEX
-- ============================================================

-- 7. Region-wise Risk Ranking
-- Business Use:
-- Geographic pricing & underwriting adjustments

SELECT 
    region_code,
    COUNT(*) AS total_policies,
    SUM(claim_status::INT) AS total_claims,
    SUM(claim_status::INT)::FLOAT / COUNT(*) AS claim_rate
FROM insurance_claims
GROUP BY region_code
ORDER BY claim_rate DESC;



-- ============================================================
-- SECTION 5: SAFETY FEATURE IMPACT
-- ============================================================

-- 8. Impact of Electronic Stability Control (ESC)

SELECT 
    is_esc,
    COUNT(*) AS total_policies,
    SUM(claim_status::INT)::FLOAT / COUNT(*) AS claim_rate
FROM insurance_claims
GROUP BY is_esc
ORDER BY claim_rate DESC;



-- 9. Impact of TPMS

SELECT 
    is_tpms,
    COUNT(*) AS total_policies,
    SUM(claim_status::INT)::FLOAT / COUNT(*) AS claim_rate
FROM insurance_claims
GROUP BY is_tpms
ORDER BY claim_rate DESC;



-- ============================================================
-- SECTION 6: RISK TIER VALIDATION
-- ============================================================

-- 10. Validate Engineered Risk Tier (from Python)

SELECT 
    risk_tier,
    COUNT(*) AS total_policies,
    SUM(claim_status::INT) AS total_claims,
    SUM(claim_status::INT)::FLOAT / COUNT(*) AS claim_rate
FROM insurance_claims
GROUP BY risk_tier
ORDER BY claim_rate DESC;



-- ============================================================
-- SECTION 7: ADVANCED ANALYTICS (WINDOW FUNCTION)
-- ============================================================

-- 11. Rank Vehicle Segments by Risk
-- Demonstrates Window Function Usage

SELECT 
    segment,
    SUM(claim_status::INT)::FLOAT / COUNT(*) AS claim_rate,
    RANK() OVER (
        ORDER BY SUM(claim_status::INT)::FLOAT / COUNT(*) DESC
    ) AS risk_rank
FROM insurance_claims
GROUP BY segment;



-- ============================================================
-- SECTION 8: CTE (BUSINESS COMPARISON)
-- ============================================================

-- 12. Identify Segments Above Portfolio Average Risk

WITH portfolio_kpi AS (
    SELECT 
        SUM(claim_status::INT)::FLOAT / COUNT(*) AS overall_claim_rate
    FROM insurance_claims
)

SELECT 
    segment,
    SUM(claim_status::INT)::FLOAT / COUNT(*) AS segment_claim_rate
FROM insurance_claims, portfolio_kpi
GROUP BY segment, portfolio_kpi.overall_claim_rate
HAVING SUM(claim_status::INT)::FLOAT / COUNT(*) > portfolio_kpi.overall_claim_rate
ORDER BY segment_claim_rate DESC;