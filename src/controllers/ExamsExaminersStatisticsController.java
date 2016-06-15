package controllers;

import database.Database;
import database.datatypes.Examiner;
import javafx.fxml.FXML;
import javafx.scene.control.TableView;

public class ExamsExaminersStatisticsController {
    @FXML
    private TableView<Examiner> tableView;
    @FXML
    public void initialize() {
        //TODO: fill tableview
		Database.instance.getExaminerTable(tableView);
    }
}
