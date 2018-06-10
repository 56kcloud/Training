# Deploy the Promethues Monitoring Stack, understand the components, and monitor containers

The wait is finally over let's get monitoring.

> **Tasks**:
>
>
> * [Task 1: Deploy the monitoring stack](#Task_1)
> * [Task 2: Prometheus Walkthrough](#Task_2)
> * [Task 3: Getting familiar with Grafana](#Task_3)
> * [Task 4: Monitoring containers with the Prom Stack](#Task_4)

## <a name="Task_1"></a>Task 1: Deploy the monitoring stack

We will now deploy a complete monitoring stack based on the following services: Prometheus, node-exporter, alertmanager, cAdvisor, and Grafana. This monitoring stack is meant to be a kick start to help you get familiar with the tools and the setup. 

This section we will walk through the various components and explain where and how to configure the stack.

1. Before we get started let's have a look at the different components

    **Prometheus:** An open-source monitoring and alerting application that stores time series data with a powerful query language. Prometheus is pull based collection of metrics.

    **node-exporter:** A Prometheus Exporter for hardware and OS metrics for *NIX kernels.

    **Alertmanager:** The Prometheus Alertmanager handles alerts sent by client applications and routes them to the proper receiver (email, SMS, Pager Duty, etc) 

    **cAdvisor:** The Container advisor collects metrics for all the running containers on each host which it runs.

    **Grafana:** The open-source dashboard visualization tool

2. Next, we will head over to the Prometheus stack project. Open [Prometheus Monitoring Stack](https://github.com/vegasbrianc/prometheus) in a new tab.

3. Open the deployed components

    **Prometheus:** `http://0.0.0.0:9090`

    **node-exporter:** `http://0.0.0.0:9100/`

    **Alertmanager:** `http://0.0.0.0:9093/`

    **cAdvisor:** `http://0.0.0.0:8080/`

    **Grafana:** `http://0.0.0.0:3000/` 
    user - `admin`
    password - `foobar`


### <a name="Task_2"></a>Task 2: Prometheus Walkthrough
Now that we deployed the Prometheus Monitoring stack let's have a look at what is running:

1. Configs CLI / UI
2. Targets
3. Alerts
4. Graph: Click on the following link which runs several Prometheus Queries [http://0.0.0.0:9090/graph?g0.range_input=1h&g0.expr=up&g0.tab=1&g1.range_input=1h&g1.expr=cadvisor_version_info&g1.tab=1&g2.range_input=1h&g2.expr=container_fs_io_current&g2.tab=1](http://0.0.0.0:9090/graph?g0.range_input=1h&g0.expr=up&g0.tab=1&g1.range_input=1h&g1.expr=cadvisor_version_info&g1.tab=1&g2.range_input=1h&g2.expr=container_fs_io_current&g2.tab=1)



### <a name="Task_3"></a>Task 3: Getting Familiar with Grafana

1. Configs / Provisioning
2. Data Sources
3. Dashboards
4. New Dashboards Import Dashboard 395 & 893



