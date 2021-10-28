
SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0;
SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0;
SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION';


DROP SCHEMA IF EXISTS `usgs` ;

CREATE SCHEMA IF NOT EXISTS `usgs` DEFAULT CHARACTER SET utf8 ;
USE `usgs` ;


DROP TABLE IF EXISTS `usgs`.`population` ;

CREATE TABLE IF NOT EXISTS `usgs`.`population` (
  `pop_id` INT NOT NULL,
  `city` VARCHAR(255) NOT NULL,
  `state` VARCHAR(2) NOT NULL,
  `pop_number` INT NOT NULL,
  `poverty_rate` DOUBLE NOT NULL,
  `percapita_income` DOUBLE NOT NULL,
  PRIMARY KEY (`pop_id`))
ENGINE = InnoDB;


DROP TABLE IF EXISTS `usgs`.`station` ;

CREATE TABLE IF NOT EXISTS `usgs`.`station` (
  `station_id` INT NOT NULL,
  `river_name` VARCHAR(255) NOT NULL,
  `city` VARCHAR(255) NOT NULL,
  `state` VARCHAR(2) NOT NULL,
  `latitude` DOUBLE NOT NULL,
  `longitude` DOUBLE NOT NULL,
  `pop_id` INT NOT NULL,
  PRIMARY KEY (`station_id`),
  INDEX `fk_station_population1_idx` (`pop_id` ASC) VISIBLE,
  CONSTRAINT `fk_station_population1`
    FOREIGN KEY (`pop_id`)
    REFERENCES `usgs`.`population` (`pop_id`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;



DROP TABLE IF EXISTS `usgs`.`method` ;

CREATE TABLE IF NOT EXISTS `usgs`.`method` (
  `method_id` INT NOT NULL,
  `type` VARCHAR(45) NOT NULL,
  PRIMARY KEY (`method_id`))
ENGINE = InnoDB;



DROP TABLE IF EXISTS `usgs`.`sample` ;

CREATE TABLE IF NOT EXISTS `usgs`.`sample` (
  `sample_id` INT NOT NULL,
  `conc_fragments` DOUBLE NOT NULL,
  `conc_pellets` DOUBLE NOT NULL,
  `conc_fibers` DOUBLE NOT NULL,
  `conc_films` DOUBLE NOT NULL,
  `conc_foams` DOUBLE NOT NULL,
  `conc_total` DOUBLE NOT NULL,
  `particle_size` VARCHAR(45) NOT NULL,
  `volume` DOUBLE NOT NULL,
  `date` DATE NOT NULL,
  `duration` DOUBLE NOT NULL,
  `station_id` INT NOT NULL,
  `method_id` INT NOT NULL,
  PRIMARY KEY (`sample_id`),
  INDEX `fk_sample_station_idx` (`station_id` ASC) VISIBLE,
  INDEX `fk_sample_method1_idx` (`method_id` ASC) VISIBLE,
  CONSTRAINT `fk_sample_station`
    FOREIGN KEY (`station_id`)
    REFERENCES `usgs`.`station` (`station_id`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `fk_sample_method1`
    FOREIGN KEY (`method_id`)
    REFERENCES `usgs`.`method` (`method_id`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;


SET SQL_MODE=@OLD_SQL_MODE;
SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS;
SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS;


-- 1 (Refer to table 1)
select p.state, max(s.conc_total) 
from population p
join station st on (st.pop_id = p.pop_id)
join sample s on (s.station_id = st.station_id)
group by p.state
order by max(s.conc_total) desc;


-- 2 (Refer to figure 4)
-- average concentration of microplastic for incomes over 20k
select 
(select avg(p.percapita_income)
from population p
where p.percapita_income > 20000) as percapita, (select avg(s.conc_total) 
from sample s join station st on (s.station_id = st.station_id) 
join population p on (st.pop_id = p.pop_id) where p.percapita_income > 20000) as total
from population p
join station st on (st.pop_id = p.pop_id)
join sample s on (s.station_id = st.station_id)
limit 1;


-- average concentration of microplastic for incomes less than 20k
select 
(select avg(p.percapita_income) 
from population p
where p.percapita_income < 20000) as percapita, (select avg(s.conc_total) 
from sample s join station st on (s.station_id = st.station_id) 
join population p on (st.pop_id = p.pop_id) where p.percapita_income < 20000) as total
from population p
join station st on (st.pop_id = p.pop_id)
join sample s on (s.station_id = st.station_id)
limit 1;

-- 3 (Refer to figure 5)
select s.station_id, s.river_name, s.city, s.state, max(sample.conc_total), m.type
from sample
join station s on (s.station_id = sample.station_id)
join population p on (p.pop_id = s.pop_id)
join method m on (m.method_id = sample.method_id)
group by s.station_id;


-- 4 (Refer to figure 6)
select population.city, population.poverty_rate, AVG(w_sa.conc_total)
from population    
join station as w_st on (population.pop_id = station.pop_id)
join sample as w_sa on (w_sa.station_id = w_st.sation_id)
group by city
order by w_sa.conc_total desc;


-- 5 (Extra query: For each month, what river had the most microplastics sum?)
select MONTH(sa.date), s.river_name, s.station_id, population.city, population.state, 
sum(sa.conc_total) from population
join station s on (s.pop_id = population.pop_id)
join sample sa on (sa.station_id = s.station_id)
group by MONTH(sa.date)
order by MONTH(sa.date) asc;
