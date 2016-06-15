package controllers;

import javafx.fxml.FXML;
import javafx.scene.chart.BarChart;
import javafx.scene.chart.XYChart;

public class VehiclesStatisticsController {
    @FXML
    private BarChart<String, Number> brandsBarChart;
    @FXML
    private BarChart<String, Number> typesBarChart;
    @FXML
    private BarChart<String, Number> rejYearBarChart;

    @FXML
    public void initialize() {

        //TODO: dane przykładowe, do poprawienia na dane z naszej bazy

        XYChart.Series typesSeries = new XYChart.Series();
        typesSeries.getData().add(new XYChart.Data("osobowy", 100));
        typesSeries.getData().add(new XYChart.Data("ciężarowy", 9));
        typesBarChart.getData().addAll(typesSeries);
        typesBarChart.setCategoryGap(100.00);

        XYChart.Series brandsSeries = new XYChart.Series();
        brandsSeries.getData().add(new XYChart.Data("Citroën C5", 33));
        brandsSeries.getData().add(new XYChart.Data("Fiat 500X", 17));
        brandsSeries.getData().add(new XYChart.Data("Ford FIESTA", 45));
        brandsBarChart.getData().addAll(brandsSeries);
        brandsBarChart.setCategoryGap(50.00);

        XYChart.Series rejSeries = new XYChart.Series();
        rejSeries.getData().add(new XYChart.Data("2012", 15));
        rejSeries.getData().add(new XYChart.Data("2013", 30));
        rejSeries.getData().add(new XYChart.Data("2014", 25));
        rejSeries.getData().add(new XYChart.Data("2015", 50));
        rejYearBarChart.getData().addAll(rejSeries);
        rejYearBarChart.setCategoryGap(30.00);
    }
}
