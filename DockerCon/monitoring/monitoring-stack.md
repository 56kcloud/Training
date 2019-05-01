# Deploy the Promethues Monitoring Stack, understand the components, and monitor containers

<img src="https://raw.githubusercontent.com/56kcloud/Training/master/img/prometheus.gif" alt="Prometheus Logo" width="150" height="99"> 

The wait is finally over let's get monitoring.

> **Tasks**:
>
>
> * [Task 1: Deploy the monitoring stack](#Task_1)
> * [Task 2: Prometheus Walkthrough](#Task_2)
> * [Task 3: Getting familiar with Grafana](#Task_3)
> * [Task 4: Monitoring containers with the Prom Stack](#Task_4)
> * [Recap topics covered in this section](#Recap)


## <a name="Task_1"></a>Task 1: Deploy the monitoring stack

We will now deploy a complete monitoring stack based on the following services: Prometheus, node-exporter, alertmanager, cAdvisor, and Grafana. This monitoring stack is meant to be a kick start to help you get familiar with the tools and the setup. 

This section we will walk through the various components and explain where and how to configure the docker Swarm stack for Prometheus.

1. For those using PWD Login to a different [PWD](https://labs.play-with-docker.com/) and create a Docker account if you don't already have one.

2. Clone the monitoring repository and change into the `prometheus` directory

  ```
  git clone https://github.com/vegasbrianc/prometheus.git
  cd prometheus
  ```

3. Deploy the Prometheus monitoring stack
 
 ```
 docker stack deploy -c docker-stack.yml prom
 ``` 
4. Next, we will head over to the Prometheus stack project. Open [Prometheus Monitoring Stack](https://github.com/vegasbrianc/prometheus) in a new tab.

5. Let's have a look at the different components deployed

    **Prometheus:** An open-source monitoring and alerting application that stores time series data with a powerful query language. Prometheus is pull based collection of metrics.

    **node-exporter:** A Prometheus Exporter for hardware and OS metrics for *NIX kernels.

    **Alertmanager:** The Prometheus Alertmanager handles alerts sent by client applications and routes them to the proper receiver (email, SMS, Pager Duty, etc) 

    **cAdvisor:** The Container advisor collects metrics for all the running containers on each host which it runs.

    **Grafana:** The open-source dashboard visualization tool

6. Open the deployed components

    **Prometheus:** `http://0.0.0.0:9090`

    **node-exporter:** `http://0.0.0.0:9100/`

    **Alertmanager:** `http://0.0.0.0:9093/`

    **cAdvisor:** `http://0.0.0.0:8080/`

    **Grafana:** `http://0.0.0.0:3000/` 
    
    user - `admin`
    password - `foobar`


### <a name="Task_2"></a>Task 2: Prometheus Walkthrough
Now that we deployed the Prometheus Monitoring stack let's have a look at what is running:

1. Configs CLI / UI: 
 * In your Terminal Navigate to the `Prometheus/prometheus` directory and open the `prometheus.yml`. Here is where we can define which targets to scrape.
 * In your terminal
 * In the Prometheus UI Click the Status menu - > Command-Line Flags (Provides commands passed to Prometheus via the `docker-compose.yml` file)
 * In the Prometheus UI Click the Status menu - > Configuration (Provides scrape target configuration informaiton)

2. Targets
* Click the Status menu -> Targets (Provides health status of Targets)
* Click the Status menu -> Service Discovery (Displays which services are being queried for Service Discovery)

3. Alerts
* In the Promethues UI Click the Alerts Menu and expand the alerts.

4. Graph: 
* In the Prometheus UI Click the Graph Menu.
* Select the last metric in the list `up` from the drop down list and click `Execute`
* Click on the following link which runs several Prometheus Queries (For PWD users change 0.0.0.0 to your PWD URL) [http://0.0.0.0:9090/graph?g0.range_input=1h&g0.expr=up&g0.tab=0&g1.range_input=1h&g1.expr=container_cpu_load_average_10s%7Bcontainer_label_com_docker_swarm_node_id!%3D%22%22%7D&g1.tab=0&g2.range_input=1h&g2.expr=container_memory_usage_bytes%7Bcontainer_label_com_docker_swarm_node_id!%3D%22%22%7D&g2.tab=0](http://0.0.0.0:9090/graph?g0.range_input=1h&g0.expr=up&g0.tab=0&g1.range_input=1h&g1.expr=container_cpu_load_average_10s%7Bcontainer_label_com_docker_swarm_node_id!%3D%22%22%7D&g1.tab=0&g2.range_input=1h&g2.expr=container_memory_usage_bytes%7Bcontainer_label_com_docker_swarm_node_id!%3D%22%22%7D&g2.tab=0)

> INFO: Prometheus does not contain Users and Roles Access Control (RBAC). It is recommended that you deploy a proxy in front of Prometheus in order to protect your deployment with users/passwords.

### <a name="Task_3"></a>Task 3: Getting Familiar with Grafana

Grafana is an amazing tool which is easy to configure and use. Since Grafana version 5.0.0 enables us to easily provision Dashboards and Datasources (Woohoo!). We will walk through the configuration of Grafana and in the next section start building Dashboards.

1. Configs / Provisioning
* In your Terminal Navigate to the `Prometheus/grafana` directory
* Open the `config.monitoring` file. Here is where we set the inital password for Grafana

2. Data Sources - All files placed in the `Prometheus/grafana/provisioning/datasources` directory will be provisioned when running `docker stack deploy`. View the `YAML` file located in this directoy

3. Dashboards - All files placed in the `Prometheus/grafana/provisioning/dashboards` directory will be provisioned when running `docker stack deploy` View the `YAML` file located in this directoy which is the Dashboard configuration and the `JSON` file is the dashoard itself.

4. Login to Grafana `http://0.0.0.0:3000/` 
    
    user - `admin`
    password - `foobar`

5. Click the gear icon (Settings) in the left bar -> Data Sources

6. Open the Prometheus Datasource. Here we can see the settings provisoned from the `YAML` file above. Notice the URL to the Datasource is the DNS name of the container.

1. At the bottom of the screen click the `Back` button 

8. In the Datasource Menu select the Plugins menu

### <a name="Task_3"></a>Task 4: Monitoring Containers / Hosts with the Prometheus Stack

In the final section we will build a Dashboard based on the Prometheus stack. We will create a simple Status Dashboard highlighting the Systems State, Containers performance, and Diskspace. Let's do this!

### Create Single Stat Uptime
1. In the Grafana UI click the + -> Create Dashboard menu
2. Select Single Stat
3. On the Panel Title click the Menu -> Edit button.
4. Click the Datasource option -> Prometheus
5. Add the `time() - avg(node_boot_time_seconds)` which takes the current time and subtracts it from the boot time to give us the average Uptime of all servers in the cluster
6. Click the Options Tab -> Set the unit to Time -> Seconds
7. Set the Decimal to 0
8. Click the General Tab and Rename the Panel to Uptime
9. Save Dashboard


### Create Single Stat Targets Online
1. At the top right of the screen click -> Add Panel(looks like a graph) -> Single Stat button and move it next to the Uptime panel
2. Add a new Single Stat
3. On the Panel Title click the Menu -> Edit button.
4. Click the Datasource option -> Prometheus
5. Add the query `sum(up)`
6. Click the Options Tab
7. Check the Background box (Invert the colors if the background is Red)
8. Set the threshold to `0,3`
9. Click the Value Mappings Menu
10. Set the following Value Mappings:
* 3 -> Up
* 2 -> Down
* 1 -> Down
* 0 -> Down
11. Click the General tab and rename the panel to `Targets Online`
12. Save Dashboard

### Create Memory Usage by Container Graph
1. At the top right of the screen click -> Add Panel -> Graph button and move it below the single stat panels
2. On the Panel Title click the Menu -> Edit button.
3. Click the Datasource option -> Prometheus
4. Add the Metric `topk(5, container_memory_usage_bytes{name=~".+"})`
5. To make the container names more readable add `{{name}}`to the Legend Format field
6. Select the Axes Tab
7. Change the Unit on `Left Y` to Data (Metric) -> Bytes
8. Switch to General Tab
9. Rename panel to `Memory Usage by Container`
10. Switch to the Display Tab
11. Under Mode options select Fill = 5
12. Save Dashboard

### Create CPU Usage by Container Graph
1. At the top right of the screen click -> Add Panel -> Graph button and move it below the single stat panels
2. On the Panel Title click the Menu -> Edit button.
3. Click the Datasource option -> Prometheus
4. Add the Metric 
`container_cpu_load_average_10s{image!=""}`
5. To make the container names more readable add `{{name}}`to the Legend Format field
6. Select the Axes Tab
7. Change the Unit on `Left Y` to None -> Percent (0-1.0)
8. Switch to General Tab
9. Rename panel to `CPU Usage by Container`
10. Switch to the Legend Tab
11. Select values `Avg` and `Current`
12. Under Options Select `Show` and `Table`
13. Save Dashboard

## Change the time range
1. The upper right hand corner of Grafana, select the quick range `15 minutes`.

Here is what the final Dashboard should look like:

<img src="https://raw.githubusercontent.com/56kcloud/Training/master/img/dashboard.png" alt="Dashboard Workshop Demo" width="500" height="250"> 

### Import Dashboards
In the last section we can quickly import Dashboards from [Grafana Dashboards](https://grafana.com/dashboards)

1. In the Grafana UI click the `+` -> Create Dashboard menu -> Import
2. Type in the ID# 395 or ID#893 and Click the `Import`button
3. Select Prometheus as the Datasource 
New Dashboards Import Dashboard 395 & 893
4. Now search [Grafana Dashboards](https://grafana.com/dashboards) for a Docker Dashboard. Select a dashboard and find the ID# of the dashboard
5. Import the Dashboad using steps 1-3 above

## <a name="Terminology"></a>Recap

What did we learn in this section?

* Deploy Alertmanager, cAdvisor, Grafana, node-exporter, & Prometheus 
* Explore the components of the Prometheus stack
* Familiarize with Grafana
* Build Grafana Dashboards

## Slides / Links / Resources 
For the next step in the tutorial, head over to [Workshop Resources](../resources/links.md)