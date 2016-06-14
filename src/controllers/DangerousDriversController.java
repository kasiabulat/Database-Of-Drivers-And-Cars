package controllers;

import database.Database;
import database.datatypes.DangerousDriver;
import javafx.fxml.FXML;
import javafx.scene.control.TableView;

public class DangerousDriversController {
    @FXML
    private TableView<DangerousDriver> tableView; //to check if ok
    @FXML
    public void initialize() {
        Database.instance.getDangerousDriversTable(tableView);
    }
}
