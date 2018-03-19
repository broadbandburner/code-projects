DELIMITER ;;
CREATE DEFINER=`Jessy_Yu`@`%` PROCEDURE `create_random_var_iterations_table`(two_square_power INT)
BEGIN

DECLARE sample_iterator INT;
DECLARE sample_max INT;
SET sample_iterator = 0;
SET sample_max = 0;

DROP TABLE IF EXISTS random_var_iterations_table;
CREATE TABLE IF NOT EXISTS random_var_iterations_table (iteration INT AUTO_INCREMENT PRIMARY KEY);
INSERT IGNORE INTO random_var_iterations_table VALUES (1);

WHILE (sample_iterator<two_square_power) DO
SET sample_max = (SELECT MAX(iteration) FROM random_var_iterations_table);
INSERT IGNORE INTO random_var_iterations_table 
SELECT iteration+sample_max FROM random_var_iterations_table;
SET sample_iterator = sample_iterator+1;
END WHILE;

END;;
DELIMITER ;


DELIMITER ;;
CREATE DEFINER=`Jessy_Yu`@`%` PROCEDURE `generate_N01_table`(target_num_samples INT)
BEGIN

DECLARE pi DOUBLE;
DECLARE sample_iterator INT;
SET pi = 0;
SET sample_iterator = 0;
SET pi = PI();


DROP TABLE IF EXISTS random_var_N01;
CREATE TABLE random_var_N01 (
iteration INT, 
norm_rv1 DOUBLE, 
norm_rv2 DOUBLE, 
norm_rv3 DOUBLE, 
norm_rv4 DOUBLE, 
norm_rv5 DOUBLE,
norm_rv6 DOUBLE,
norm_rv7 DOUBLE, 
norm_rv8 DOUBLE, 
norm_rv9 DOUBLE
);

WHILE (sample_iterator<target_num_samples) DO
INSERT IGNORE INTO random_var_N01 (
iteration, 
norm_rv1, 
norm_rv2, 
norm_rv3, 
norm_rv4, 
norm_rv5,
norm_rv6,
norm_rv7, 
norm_rv8, 
norm_rv9) VALUES(
sample_iterator,
SQRT(-2*LN(RAND()))*SIN(2*pi*RAND()),
SQRT(-2*LN(RAND()))*SIN(2*pi*RAND()),
SQRT(-2*LN(RAND()))*SIN(2*pi*RAND()),
SQRT(-2*LN(RAND()))*SIN(2*pi*RAND()),
SQRT(-2*LN(RAND()))*SIN(2*pi*RAND()),
SQRT(-2*LN(RAND()))*SIN(2*pi*RAND()),
SQRT(-2*LN(RAND()))*SIN(2*pi*RAND()),
SQRT(-2*LN(RAND()))*SIN(2*pi*RAND()),
SQRT(-2*LN(RAND()))*SIN(2*pi*RAND())
);
SET sample_iterator = sample_iterator+1;
END WHILE;
CREATE INDEX id_1 ON random_var_N01(iteration);
END;;
DELIMITER ;


call generate_N01_table(500);

DELIMITER ;;
CREATE DEFINER=`Jessy_Yu`@`%` PROCEDURE `fill_random_var_test`(target_num_samples INT, 
norm_rv1_mu DOUBLE, norm_rv1_sigma DOUBLE, norm_rv1_skew DOUBLE,
norm_rv2_mu DOUBLE, norm_rv2_sigma DOUBLE, norm_rv2_skew DOUBLE,
norm_rv3_mu DOUBLE, norm_rv3_sigma DOUBLE, norm_rv3_skew DOUBLE,
norm_rv4_mu DOUBLE, norm_rv4_sigma DOUBLE, norm_rv4_skew DOUBLE,
norm_rv5_mu DOUBLE, norm_rv5_sigma DOUBLE, norm_rv5_skew DOUBLE,
norm_rv6_mu DOUBLE, norm_rv6_sigma DOUBLE, norm_rv6_skew DOUBLE,
norm_rv7_mu DOUBLE, norm_rv7_sigma DOUBLE, norm_rv7_skew DOUBLE,
norm_rv8_mu DOUBLE, norm_rv8_sigma DOUBLE, norm_rv8_skew DOUBLE,
norm_rv9_mu DOUBLE, norm_rv9_sigma DOUBLE, norm_rv9_skew DOUBLE)
BEGIN
DECLARE pi DOUBLE;
DECLARE sample_iterator INT(11);
DECLARE random_set_size INT(11);
DECLARE seed INT(11);
SET pi = 0;
SET sample_iterator = 0;
SET random_set_size = 0;
SET seed = 0;
SET pi = PI();
SET random_set_size = IFNULL((SELECT COUNT(iteration) FROM random_var_N01),0);
SET seed = random_set_size-target_num_samples;

DROP TABLE IF EXISTS random_var_insert_tracker;
CREATE TABLE IF NOT EXISTS random_var_insert_tracker(str VARCHAR(255), time_stamp DATETIME);
INSERT IGNORE INTO random_var_insert_tracker VALUES ('start', NOW());

DROP TABLE IF EXISTS random_var_test;
CREATE TABLE random_var_test 
(
iteration INT, 
norm_rv1 FLOAT, 
norm_rv2 FLOAT, 
norm_rv3 FLOAT, 
norm_rv4 FLOAT, 
norm_rv5 FLOAT, 
norm_rv6 FLOAT, 
norm_rv7 FLOAT, 
norm_rv8 FLOAT, 
norm_rv9 FLOAT);

SET @random_set_size = (SELECT COUNT(iteration) FROM random_var_N01);
SET @seed = @random_set_size-target_num_samples;

INSERT IGNORE INTO random_var_test
SELECT 
A.iteration,
norm_rv1_mu+norm_rv1_sigma*SQRT(-2*LN(RAND()))*SIN(2*pi*RAND()),
norm_rv2_mu+norm_rv2_sigma*SQRT(-2*LN(RAND()))*SIN(2*pi*RAND()),
norm_rv3_mu+norm_rv3_sigma*SQRT(-2*LN(RAND()))*SIN(2*pi*RAND()),
/* Box Muller Method ENDS HERE */

/* Remove additional unused variables to increase speed.*/
/* Comment this in if adding random variables. */

norm_rv4_mu+norm_rv4_sigma*SQRT(-2*LN(RAND()))*SIN(2*pi*RAND()),
norm_rv5_mu+norm_rv5_sigma*SQRT(-2*LN(RAND()))*SIN(2*pi*RAND()),
norm_rv6_mu+norm_rv6_sigma*SQRT(-2*LN(RAND()))*SIN(2*pi*RAND()),
norm_rv7_mu+norm_rv7_sigma*SQRT(-2*LN(RAND()))*SIN(2*pi*RAND()),
norm_rv8_mu+norm_rv8_sigma*SQRT(-2*LN(RAND()))*SIN(2*pi*RAND()),
norm_rv9_mu+norm_rv9_sigma*SQRT(-2*LN(RAND()))*SIN(2*pi*RAND())


FROM random_var_iterations_table A
WHERE A.iteration<target_num_samples;
DELETE FROM random_var_test WHERE norm_rv1 <= 0 or norm_rv2 <= 0 or norm_rv3 <= 0 or norm_rv4 <= 0 or norm_rv5 <= 0 or norm_rv6 <= 0 or norm_rv7 <= 0 or norm_rv8 <= 0 or norm_rv9 <=0;
INSERT IGNORE INTO random_var_insert_tracker VALUES ('rapidgen_complete', NOW());

/*
DROP TABLE IF EXISTS Dashboard.forecaster_random_var_test;
CREATE TABLE Dashboard.forecaster_random_var_test (iteration INT, trailer_views_rv DOUBLE, trailer_likes_rv DOUBLE, trailer_dislikes_rv DOUBLE, norm_rv1 DOUBLE, norm_rv2 DOUBLE, norm_rv3 DOUBLE, norm_rv4 DOUBLE, norm_rv5 DOUBLE);
WHILE (sample_iterator<target_num_samples) DO
INSERT IGNORE INTO Dashboard.forecaster_random_var_test (iteration, trailer_views_rv, trailer_likes_rv, trailer_dislikes_rv,norm_rv1, norm_rv2, norm_rv3, norm_rv4, norm_rv5) VALUES(
sample_iterator,
SQRT(
GREATEST(
trailer_views_mu+trailer_views_sigma*SQRT(-2*LN(RAND()))*SIN(2*pi*RAND())
,0)
),
trailer_likes_mu+trailer_likes_sigma*SQRT(-2*LN(RAND()))*SIN(2*pi*RAND()),
trailer_dislikes_mu+trailer_dislikes_sigma*SQRT(-2*LN(RAND()))*SIN(2*pi*RAND()),
*/
/* Box Muller Method ENDS HERE */

/* Remove additional unused variables to increase speed.*/
/* Comment this in if adding random variables. */
/*
mu1+sigma1*SQRT(-2*LN(RAND()))*SIN(2*pi*RAND()),
mu2+sigma2*SQRT(-2*LN(RAND()))*SIN(2*pi*RAND()),
mu3+sigma3*SQRT(-2*LN(RAND()))*SIN(2*pi*RAND()),
mu4+sigma4*SQRT(-2*LN(RAND()))*SIN(2*pi*RAND()),
mu5+sigma5*SQRT(-2*LN(RAND()))*SIN(2*pi*RAND())
*/
/* Comment this out if adding random variables. */
/*
0,
0,
0,
0,
0
);
SET sample_iterator = sample_iterator+1;
END WHILE;
INSERT IGNORE INTO forecaster_random_var_insert_tracker VALUES ('realtime_gen_complete', NOW());
*/

END;;
DELIMITER ;
