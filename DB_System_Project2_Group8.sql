---------------------------------------------------
----- 1.查詢留言數前五名的留言者名稱、留言數
---------------------------------------------------

--SQL:
WITH CmtPosterCount AS
(
	SELECT 
	CMTPOSTER,
	count(*) as cmt_count
	FROM PTT_MOVIE_COMMENT
	WHERE 1=1
	GROUP BY CMTPOSTER
	ORDER BY count(*) DESC
)
SELECT * FROM CmtPosterCount
WHERE 1=1
AND rownum<=5

---------------------------------------------------
----- 2.查詢最多留言數的文章ID、文章標題、留言數
---------------------------------------------------

--SQL:
SELECT * FROM (
	SELECT 
	a.system_id,
	a.arttitle,
	count(*) as cmt_count 
	FROM PTT_MOVIE a
	JOIN PTT_MOVIE_COMMENT b on a.system_id = b.system_id
	WHERE 1=1
	GROUP BY a.system_id,a.arttitle
	ORDER BY count(*) DESC
)
WHERE 1=1
AND rownum<=1

--改善：加入PTT_MOVIE的主鍵及PTT_MOVIE_COMMENT的外鍵
ALTER TABLE GROUP8.PTT_MOVIE ADD PRIMARY KEY (system_id);

ALTER TABLE GROUP8.PTT_MOVIE_COMMENT
ADD FOREIGN KEY (system_id) REFERENCES GROUP8.PTT_MOVIE (system_id);

--------------------------------------------------------------------------------------------------------------------
----- 3.查詢標題包含「關於我和鬼變成家人的那件事」「黑的教育」「捍衛任務4」「星際異攻隊3」的文章數排名及留言數排名
--------------------------------------------------------------------------------------------------------------------
--改善前SQL:
WITH MOVIE AS (
	SELECT '關於我和鬼變成家人的那件事' as Movie_Name FROM dual
	union all
	SELECT '黑的教育' as Movie_Name FROM dual
	union all
	SELECT '捍衛任務4' as Movie_Name FROM dual
	union all
	SELECT '星際異攻隊3' as Movie_Name FROM dual
),
Article_Rank AS (
	SELECT 
	b.Movie_Name,
	count(*) as art_count,
	ROW_NUMBER() OVER (ORDER BY count(*) DESC) as art_count_rank 
	FROM PTT_MOVIE a, MOVIE b
	WHERE 1=1
	AND instr(a.ARTTITLE,b.Movie_Name)>0
	GROUP BY b.Movie_Name
),
Comment_Rank AS (
	SELECT 
	b.Movie_Name,
	count(*) as cmt_count,
	ROW_NUMBER() OVER (ORDER BY count(*) DESC) as cmt_count_rank 
	FROM PTT_MOVIE a, MOVIE b, PTT_MOVIE_COMMENT c 
	WHERE 1=1
	AND a.system_id = c.system_id
	AND instr(a.ARTTITLE,b.Movie_Name)>0
	GROUP BY b.Movie_Name
)
SELECT * FROM Article_Rank NATURAL JOIN Comment_Rank

--改善：針對PTT_MOVIE的ARTTITLE欄位加入Index
CREATE INDEX idx_movie_arttitle ON GROUP8.PTT_MOVIE (ARTTITLE);

--改善後SQL:
WITH MOVIE AS (
	SELECT '關於我和鬼變成家人的那件事' as Movie_Name FROM dual
	union all
	SELECT '黑的教育' as Movie_Name FROM dual
	union all
	SELECT '捍衛任務4' as Movie_Name FROM dual
	union all
	SELECT '星際異攻隊3' as Movie_Name FROM dual
),
Article_Rank AS (
    SELECT 
    b.Movie_Name,
    count(*) as art_count,
    ROW_NUMBER() OVER (ORDER BY count(*) DESC) as art_count_rank 
    FROM PTT_MOVIE a, MOVIE b
    WHERE 1=1
    --AND instr(a.ARTTITLE,b.Movie_Name)>0
    AND a.ARTTITLE LIKE '%' || b.Movie_Name || '%'
    GROUP BY b.Movie_Name
),
Comment_Rank AS (
    SELECT 
    b.Movie_Name,
    count(*) as cmt_count,
    ROW_NUMBER() OVER (ORDER BY count(*) DESC) as cmt_count_rank 
    FROM PTT_MOVIE a, MOVIE b, PTT_MOVIE_COMMENT c 
    WHERE 1=1
    AND a.system_id = c.system_id
    --AND instr(a.ARTTITLE,b.Movie_Name)>0
    AND a.ARTTITLE LIKE '%' || b.Movie_Name || '%'
    GROUP BY b.Movie_Name
)
SELECT * FROM Article_Rank NATURAL JOIN Comment_Rank

