package controllers;

import database.Database;
import database.datatypes.ExamCenter;
import javafx.fxml.FXML;
import javafx.scene.control.TableView;

public class ExamsTrainingCentersStatisticsController {
    @FXML
    private TableView<ExamCenter> tableView;
    @FXML
    public void initialize() {
        Database.instance.getExamCenterTable(tableView);    //TODO: fill tableview
    }
}
