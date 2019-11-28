#ifndef SAILCON_H
#define SAILCON_H

#include <QObject>
#include <QNetworkAccessManager>
#include <QSettings>
#include <QSqlDatabase>
#include <QSqlQuery>
#include <QSqlTableModel>
#include <QCryptographicHash>

#include "dukeconbackend.h"

class Sailcon : public QObject {
    Q_OBJECT
public:
    explicit Sailcon(QObject *parent = nullptr);
    ~Sailcon();
    DukeconBackend *getDukeconBackend();

signals:

public slots:

private:
    QNetworkAccessManager *networkAccessManager;
    DukeconBackend *dukeconBackend;
    QSettings settings;

};


#endif // SAILCON_H
