package controllers;

import database.Database;
import database.datatypes.LicenseCategory;
import javafx.fxml.FXML;
import javafx.scene.chart.BarChart;
import javafx.scene.chart.XYChart;

public class ExamsCategoriesStatisticsController {
    @FXML
    private BarChart<String, Number> categoriesBarChart;

    @FXML
    public void initialize() {

        //TODO: dane przykładowe, do poprawienia na dane z naszej bazy
        //może być kilka różnych serii np. dla różnych lat, albo podział kobiety/mężczyźni

        final XYChart.Series<String,Number> series1 = new XYChart.Series<>();
		for(final LicenseCategory licenseCategory: Database.instance.getLicenseCategory())
		{
			series1.getData().add(new XYChart.Data<>(licenseCategory.name, licenseCategory.count));
		}
       // series1.getData().add(new XYChart.Data("A1", 12));
       // series1.getData().add(new XYChart.Data("A", 100));
       // series1.getData().add(new XYChart.Data("B", 80));
       // series1.getData().add(new XYChart.Data("D", 30));
        categoriesBarChart.getData().addAll(series1);
    }
}
