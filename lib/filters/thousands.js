module.exports = {
  thousands: function (num) {
    return typeof num === "number"
      ? new Intl.NumberFormat("en-us").format(num)
      : num;
  },
};
