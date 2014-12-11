# Model formalization

## Household agent
- Has:
	- Members -> List of People
	- Location
	- Family -> Set of households
- Calculates:
	- Resistance to move, based on:
		- Time spent living in current city
		- Distance to family members
		- Closeness to current location
		- Household size
		- Age
			- over 68 resistance increases
	- Willingness to move, based on:
		- List of attractiveness per city based on:
			- Job offers
			- Intrinsic attractiveness of city
			- Age
				- Between 16 and 23
					- for low education: short distance
					- for high education: longer distance
				- Between 23 and 30 -> Many long
				- Between 30 and 55 -> Long distance
				- Between 55 - 68 -> Long distance
- Does:
	- Move, based on:
		- If household has not moved for past x years
		- Household moves to city with highest attractiveness if it is higher than resistance
		- Progress in life stage, defined as:
			- If member with age between 16-22:
				- remove member from household and spawn new household
			- If household size is 1 and age of member is 20-25:
				- merge with another random household in same location
			- if household size is >= 2 and age of both members 23-30
				- x% chance of adding new member to household with age 0
			- If age > 75
				- x% chance of dying, remove member from household
				- if household size == 0, delete household
			- A household's life stage is based on the age of the eldest person in that household



## People
- Have: 
	- Age
	- Sex
	- Job category
	- Education level (is this still needed?)
- Are not modelled as agents! Households are the agents.

## Cities
Cities have jobs. There are a number of job categories:
- Fixed percentage required jobs, such as:
	- Agricultural
	- Service
- Growth inducing jobs, such as:
	- Manufacturing
	- ICT
	- Finance
	- Engineering

Fixed percentage required jobs are job types where the city has a percentage of workers required for that job type. So these jobs do not make the city attract more of that job type. This is true for service jobs. Only X% of a cities workers needs to be service workers. We include two types of fixed percentage jobs: agricultural and service jobs.
So people who 'specialize' in service jobs for example, will find cities more attractive when the percentage of jobs taken in that category is lower than the desired percentage and will find cities less attractive where it is higher.

The job offers for growth inducing categories are designed to increase the attractiveness of a city for people with that job category the more people of that category live in that city. This means that for example when there is a lot of ICT related jobs in a city, more people with that specialization will want to live in this city, which will attract more ICT jobs, which will make the city even more attractive for these people and so on. These job types are not limited by a 'desired percentage' as the fixed percentage required jobs are, therefore they are called growth inducing jobs.

Cities also have an intrinsic attractiveness:
- ...

## Assumed
Moving because of need for bigger house is most often within city limits -> Out of scope of this project

# Narrative
Assume that a tick is a year in real time.

When a household becomes active it will perform the following steps:
- Increase the age of each member by one year
- Check if there are any life stage progressions
	- If child matures:
		- Remove child from current household and spawn new household with family connected to this household
		- Put child on household list to be processed later
	- If child is born:
		- Add child to household
		- Household will not move this year
	- If member dies:
		- Remove member from household
		- Household will not move this year
- Calculate resistance to move, based on:
	- Time spent living in current city
	- Distance to family members
	- Closeness to current location
	- Household size
	- Age
		- over 68 resistance increases
- Calculate willingness to move, based on:
	- For each household member:
		- calculate attractiveness of city based on city attractiveness per job category
	- Add intrinsic attractiveness of city
	- Age
		- Between 16 and 23
			- for low education: short distance
			- for high education: longer distance
		- Between 23 and 30 -> Many long
		- Between 30 and 55 -> Long distance
		- Between 55 - 68 -> Long distance
- Decide whether to move:
	- if highest willingness to move > resistance to move
	- AND household hasn't moved in past x years
	- Move to city with highest score


ARE WE ADDING SOMETHING WITH DISTANCE FROM JOBS?
		

## Job categories (source http://statline.cbs.nl/Statweb/publication/?DM=SLNL&PA=71738ned&D1=1-26,32-34&D2=a&D3=a&D4=0&D5=l&VW=T)

Manufacturing 	- Mostly interested in less dense cities
Service 		- Fixed percentage job

- Primary sector - Farming, raw material mining etc. (2% of people)
- Secundary sector - Manufacturing (16%)
- Tertiary sector 	- commercial (40%)
	- Services		32%
	- Financial     4%
	- IT			4%
- Quartary sector 	- non-profit (34%)
- Jobless  		(8%)

primary sector will be attracted to non-city patches
secundary sector will be attracted to areas with low population density
services will attempt to spread evenly according to population
financial will be attracted to areas with higher % financial workers
IT will be attracted to areas with higher % IT workers
Quartary sector will attempt to spread evenly according to population
Jobless do not care