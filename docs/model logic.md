# Model logic
## Household agent
Agents in the ABM model represent households. A household has members, which is coded as a list of people. Every household member has the following attributes:
-	Age (0 to 100)
-	Job preference (1 to 7)
-	Sex (Male / Female)
Next to household members, a household also has a location. This location can be in one of the cities or on a patch in the countryside. 
Model setup
The model starts by choosing locations for the X number of cities the model is run. Then the X number of households are divided over these cities and the countryside. The first city is always placed in the middle of the map, after which the other cities are distributed randomly in a circle with a certain width around this first city. This width is minimally 250 patches and maximally 500 patches. The households are distributed over the cities and the countryside. 40% of the households are placed in the cities whereas 60% of the households are placed in the countryside at the start of the model run.

## Life stage progress
Every member in a household gets older each tick of the model. They progress through different life stages in the model according to the flowchart shown in figure 1.
When a child is born a member is added to the household of 2 or more members. A child is aged 0 and the sex is chosen randomly. At birth they are already given a job preference from 1 to 7: 
1.	Primary sector jobs (2% of people)
2.	Secondary sector jobs (16% of people)
3.	Tertiary sector jobs; Services (32% of people)
4.	Tertiary sector jobs; Financial (4% of people)
5.	Tertiary sector jobs; IT (4% of people)
6.	Quartary sector jobs; Non-Profit (34% of people)
7.	Jobless (8% of people)

Each tick the child grows a year older. Between the ages of 16 and 23 the child will move out of its parents’ home and move to the city that is most attractive for him/her. This will spawn a new household in the model.
Between the ages of 23 and 30 adults will then find partners that live in the same location. When a couple is found, the households are merged into one household and they stay in the same location. It is possible for older people to be in search for a partner as well (<50 years old), because some people are not able to find a partner before they turn 30.

The couple then has a change to reproduce each year equal to 1 in 7. In order for a couple to reproduce they both have to be younger than 40. When a child is born, this child is added to the household and that child’s life stage progress starts at the beginning of the flowchart. 
Adults retire when they are 65 years old. They then become more interested in moving to the countryside, thereby mimicking the moving behaviour of the elderly who move out of the cities. Adults die between the age of 60 and 100. This is coded using a normal distribution with u = 80 and s = 6. When the last member of a household dies, the household is removed from the system. 

### Moving
Each household has a resistance to move and a willingness to move which is actually the attractiveness of a city for each household. When the attractiveness of one or a number of cities is higher than the household’s resistance to move, the household will move randomly to one of the cities which attractiveness exceeds their resistance to move. Figure 2 shows the factors that influence the resistance to move and the attractiveness of a city.

## Resistance to move
As you can see in figure 2, the resistance to move is influenced by three factors:
-	Number of children in a household
-	Time since moving
-	Age of adult household members

The effects of these factors are summarized in a graph which is shown in figure 3. The x-axis show the number of years since the last time the household moved to another location. This resistance to move (y-axis) can then become higher when a household has children and the lowest point of the graph is moved to the right when a household is relatively old, so the elderly do not move as often as young people do. The resistance to move is a value between 0 and 1. 

## Attractiveness of a city
The attractiveness of a city to a certain household is dependent on the job preferences in that household and the distance from their current location to a city. The attractiveness of a city also takes on values between 0 and 1. 

We assume that people prefer to stay at their current location when a more attractive city is very close by their current location. We also assume that people do not move to cities that are very far from their current location. This translates into lower (-0.1) city attractiveness for cities that are close by (<100 pacthes) or very far away from a household’s current location (>250 patches). 

The attractiveness is also influenced by the household members’ job preference. Each city has a unique attractiveness score for each job based on the amount of people in the city with that job. The way in which this attractiveness is determined differs per job type:

Cities are more attractive to manufacturing and agriculture jobs if they are relatively small cities. The size of cities in this case is used as a proxy for land prices, which greatly influence the profitability for these types of jobs.

Jobs in the service and non-profit domain are not influenced by city size in general. Instead, jobs in these domains are expected to spread evenly over all cities. This means that cities with less service jobs than average is more attractive for service jobs.

There are also two groups of jobs which show a networking effect. Cities are more attractive for IT and finance jobs if more people are working in that domain in the city. 
Finally, each city is evenly attractive for jobless people. In Appendix A attractiveness graphs are presented for the different job types. 

### Attractiveness of the countryside
The attractiveness of the countryside is a constant value for the different job types, so that for IT and finance job types the countryside is not very attractive, but for primary and secondary jobs the countryside is very attractive. This results in the following values from job type 1 to 7: 0.55; 0.55; 0.50; 0.45; 0.45; 0.5; 0.5.
