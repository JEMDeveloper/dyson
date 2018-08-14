var exec = require('cordova/exec');

var PLUGIN_NAME = "Dyson";

var Dyson = {

    setEnvironment: function (success,failure,environment) {
        exec(success, failure, PLUGIN_NAME, 'setEnvironment', [environment]);
    },

    startTransmissionOfEnrollmentEntry: function (success,failure,data) {
        var enrollmentData = data.enrollmentData;
        var messageId = data.messageId;

        exec(success, failure, PLUGIN_NAME, 'startTransmissionOfEnrollmentEntry', [enrollmentData,messageId]);
    },

    startTransmissionOfBlob: function (success,failure,data) {
        var enrollmentData = data.enrollmentData;
        var messageId = data.messageId;
        var blobContainer = data.blobContainer;

        exec(success, failure, PLUGIN_NAME, 'startTransmissionOfBlob', [enrollmentData,messageId,blobContainer]);
    },

    getPendingUploads: function (success,failure) {
        exec(success, failure, PLUGIN_NAME, 'getPendingUploads', []);
    },

    startTransmissionOfUploadsOnLogin: function () {
        exec(null, null, PLUGIN_NAME, 'startTransmissionOfUploadsOnLogin', []);
    }

};

module.exports = Dyson;