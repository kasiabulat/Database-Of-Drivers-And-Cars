package controllers;

import javafx.event.ActionEvent;
import javafx.fxml.FXML;
import javafx.scene.chart.BarChart;
import javafx.scene.chart.XYChart;
import javafx.scene.control.Button;
import javafx.scene.control.TableView;

public class ExamsCategoriesStatisticsController {
    @FXML
    private BarChart<String, Number> caterogiresBarChart;

    @FXML
    public void initialize() {

        //TODO: dane przykładowe, do poprawienia na dane z naszej bazy
        //może być kilka różnych serii np. dla różnych lat, albo podział kobiety/mężczyźni

        XYChart.Series series1 = new XYChart.Series();
        series1.getData().add(new XYChart.Data("A1", 12));
        series1.getData().add(new XYChart.Data("A", 100));
        series1.getData().add(new XYChart.Data("B", 80));
        series1.getData().add(new XYChart.Data("D", 30));
        caterogiresBarChart.getData().addAll(series1);
    }
}
