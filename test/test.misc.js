(function() {

  describe("Ewok", function() {
    return it("should exist", function() {
      expect(Ewok).to.not.be.undefined;
      expect(Ewok.App).to.not.be.undefined;
      return expect(Ewok.View).to.not.be.undefined;
    });
  });

}).call(this);
