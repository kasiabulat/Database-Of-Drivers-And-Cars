package controllers;

import database.Database;
import database.datatypes.Exam;
import javafx.event.ActionEvent;
import javafx.fxml.FXML;
import javafx.fxml.FXMLLoader;
import javafx.scene.Parent;
import javafx.scene.Scene;
import javafx.scene.control.Button;
import javafx.scene.control.TableView;
import javafx.stage.Stage;

import java.io.IOException;

public class ExamsController {
    @FXML
    private TableView<Exam> tableView;
    @FXML
    private Button moreInfoButton;
    @FXML
    private Button categoriesStatisticsButton;
    @FXML
    private Button examsStatisticsButton;
    @FXML
    private Button examinersStatisticsButton;
    @FXML
    private Button trainingCentersStatisticsButton;

    @FXML
    public void initialize() {
        Database.instance.getExamsTable( tableView);
    }

    @FXML
    public void showCategoriesStatistics(final ActionEvent event) {
        try {
            final Parent root = FXMLLoader.load(getClass().getResource("../FXML/examsCategoriesStatisticsWindow.fxml"));
            final Stage stage = new Stage();
            stage.setTitle("Kategorie - statystyki");
            stage.setScene(new Scene(root, 450, 310));
            stage.show();

        } catch (final IOException e) {
            e.printStackTrace();
        }
    }
    @FXML
    public void showExamsStatistics(final ActionEvent event) {
        try {
            final Parent root = FXMLLoader.load(getClass().getResource("../FXML/examsStatisticsWindow.fxml"));
            final Stage stage = new Stage();
            stage.setTitle("Egzaminy - statystyki");
            stage.setScene(new Scene(root, 450, 310));
            stage.show();

        } catch (final IOException e) {
            e.printStackTrace();
        }
    }
    @FXML
    public void showTrainingCentersStatistics(final ActionEvent event) {
        try {
            final Parent root = FXMLLoader.load(getClass().getResource("../FXML/examsTrainingCentersStatisticsWindow.fxml"));
            final Stage stage = new Stage();
            stage.setTitle("Ośrodki - statystyki");
            stage.setScene(new Scene(root, 510, 480));
            stage.show();

        } catch (final IOException e) {
            e.printStackTrace();
        }
    }
    @FXML
    public void showExaminersStatistics(final ActionEvent event) {
        try {
            final Parent root = FXMLLoader.load(getClass().getResource("../FXML/examsExaminersStatisticsWindow.fxml"));
            final Stage stage = new Stage();
            stage.setTitle("Egzaminatorzy - statystyki");
            stage.setScene(new Scene(root, 510, 480));
            stage.show();

        } catch (final IOException e) {
            e.printStackTrace();
        }
    }
}
