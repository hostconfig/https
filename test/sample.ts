import chai from 'chai'
import chaiHttp from 'chai-http'

import { app } from '../src'

chai.use(chaiHttp)
chai.should()

describe("API /health", () => {
  it("it should return 200", done => {
    chai
      .request(app)
      .get("/health")
      .end((err, res) => {
        res.should.have.status(200);
        done();
      });
  });
});

describe("API /", () => {
  it("it should return HTML Welcome message", done => {
    chai
      .request(app)
      .get("/")
      .end((err, res) => {
        res.should.have.status(200)
        res.should.to.be.html
        // res.text.should.be.equal("Hello Docker World\n")
        done()
      })
  })
})
